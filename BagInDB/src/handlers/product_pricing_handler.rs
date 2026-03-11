use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde_json::json;
use sqlx::PgPool;
use std::time::Duration;
use uuid::Uuid;

use crate::cache::{keys, CacheClient};
use crate::models::{
    CreateProductPricingRequest, ProductPricing, ProductPricingQuery, UpdateProductPricingRequest,
};

/// List product pricing records with optional filters
pub async fn list_product_pricing(
    State(pool): State<PgPool>,
    Query(query): Query<ProductPricingQuery>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let page = query.page.unwrap_or(0);
    let limit = query.limit.unwrap_or(20).min(100);
    let offset = page * limit;

    // 필터 조건 구성
    let mut conditions = vec!["TRUE".to_string()];

    if let Some(ref product_id) = query.product_id {
        conditions.push(format!("product_id = '{}'", product_id));
    }
    if let Some(ref marketplace) = query.marketplace {
        conditions.push(format!("marketplace = '{}'", marketplace));
    }
    if let Some(is_current) = query.is_current {
        conditions.push(format!("is_current = {}", is_current));
    }

    let where_clause = conditions.join(" AND ");
    let sql = format!(
        "SELECT * FROM product_pricing WHERE {} ORDER BY created_at DESC LIMIT $1 OFFSET $2",
        where_clause
    );

    let pricing_records = sqlx::query_as::<_, ProductPricing>(&sql)
        .bind(limit)
        .bind(offset)
        .fetch_all(&pool)
        .await
        .map_err(|e| {
            tracing::error!("Failed to fetch product pricing: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": "Failed to fetch product pricing"})),
            )
        })?;

    Ok(Json(json!({
        "data": pricing_records,
        "page": page,
        "limit": limit,
    })))
}

/// Get product pricing by ID
pub async fn get_product_pricing(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let cache_key = keys::pricing(id);

    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached)) = cache_client.get::<ProductPricing>(&cache_key).await {
            return Ok(Json(json!({"data": cached, "cached": true})));
        }
    }

    let pricing =
        sqlx::query_as::<_, ProductPricing>("SELECT * FROM product_pricing WHERE id = $1")
            .bind(id)
            .fetch_optional(&pool)
            .await
            .map_err(|e| {
                tracing::error!("Database error: {:?}", e);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(json!({"error": "Database error"})),
                )
            })?;

    match pricing {
        Some(pricing) => {
            if let Some(Extension(cache_client)) = cache {
                let _ = cache_client
                    .set(&cache_key, &pricing, Duration::from_secs(600))
                    .await;
            }
            Ok(Json(json!({"data": pricing})))
        }
        None => Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Product pricing not found"})),
        )),
    }
}

/// Get price history for a product (for charts)
pub async fn get_price_history_for_product(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(product_id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let cache_key = format!("price_history:{}", product_id);

    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached)) = cache_client.get::<Vec<ProductPricing>>(&cache_key).await {
            return Ok(Json(json!({"data": cached, "cached": true})));
        }
    }

    let pricing = sqlx::query_as::<_, ProductPricing>(
        "SELECT * FROM product_pricing WHERE product_id = $1 ORDER BY created_at ASC",
    )
    .bind(product_id)
    .fetch_all(&pool)
    .await
    .map_err(|e| {
        tracing::error!("Database error: {:?}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": "Database error"})),
        )
    })?;

    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client
            .set(&cache_key, &pricing, Duration::from_secs(1800))
            .await;
    }

    Ok(Json(json!({"data": pricing})))
}

/// Get current (latest) pricing for a product - returns all marketplaces
pub async fn get_current_pricing_for_product(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(product_id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let cache_key = keys::product_current_pricing(product_id);

    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached)) = cache_client.get::<Vec<ProductPricing>>(&cache_key).await {
            return Ok(Json(json!({"data": cached, "cached": true})));
        }
    }

    // 각 마켓플레이스별 최신 가격 조회
    let pricing = sqlx::query_as::<_, ProductPricing>(
        r#"
        SELECT DISTINCT ON (marketplace) *
        FROM product_pricing
        WHERE product_id = $1
        ORDER BY marketplace, created_at DESC
        "#,
    )
    .bind(product_id)
    .fetch_all(&pool)
    .await
    .map_err(|e| {
        tracing::error!("Database error: {:?}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": "Database error"})),
        )
    })?;

    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client
            .set(&cache_key, &pricing, Duration::from_secs(1800))
            .await;
    }

    // 최저가 계산
    let lowest_price = pricing.iter().filter_map(|p| p.price).min();

    Ok(Json(json!({
        "data": pricing,
        "lowest_price": lowest_price
    })))
}

/// Create new product pricing
pub async fn create_product_pricing(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Json(payload): Json<CreateProductPricingRequest>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let pricing = sqlx::query_as::<_, ProductPricing>(
        r#"
        INSERT INTO product_pricing (
            product_id, currency, price,
            market, marketplace, price_type,
            valid_from, valid_until,
            source, notes, is_current
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
        "#,
    )
    .bind(payload.product_id)
    .bind(payload.currency.unwrap_or_else(|| "USD".to_string()))
    .bind(payload.price)
    .bind(payload.market)
    .bind(payload.marketplace)
    .bind(payload.price_type)
    .bind(
        payload
            .valid_from
            .unwrap_or_else(|| chrono::Utc::now().date_naive()),
    )
    .bind(payload.valid_until)
    .bind(payload.source)
    .bind(payload.notes)
    .bind(payload.is_current.unwrap_or(true))
    .fetch_one(&pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to create product pricing: {:?}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": "Failed to create product pricing"})),
        )
    })?;

    // 캐시 무효화
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client
            .delete(&keys::product_current_pricing(payload.product_id))
            .await;
        let _ = cache_client
            .delete(&format!("price_history:{}", payload.product_id))
            .await;
    }

    Ok((StatusCode::CREATED, Json(json!({"data": pricing}))))
}

/// Update product pricing
pub async fn update_product_pricing(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
    Json(payload): Json<UpdateProductPricingRequest>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let pricing = sqlx::query_as::<_, ProductPricing>(
        r#"
        UPDATE product_pricing SET
            currency = COALESCE($2, currency),
            price = COALESCE($3, price),
            market = COALESCE($4, market),
            marketplace = COALESCE($5, marketplace),
            price_type = COALESCE($6, price_type),
            valid_from = COALESCE($7, valid_from),
            valid_until = COALESCE($8, valid_until),
            source = COALESCE($9, source),
            notes = COALESCE($10, notes),
            is_current = COALESCE($11, is_current),
            updated_at = NOW()
        WHERE id = $1
        RETURNING *
        "#,
    )
    .bind(id)
    .bind(&payload.currency)
    .bind(&payload.price)
    .bind(&payload.market)
    .bind(&payload.marketplace)
    .bind(&payload.price_type)
    .bind(&payload.valid_from)
    .bind(&payload.valid_until)
    .bind(&payload.source)
    .bind(&payload.notes)
    .bind(&payload.is_current)
    .fetch_optional(&pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to update product pricing: {:?}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": "Failed to update product pricing"})),
        )
    })?;

    match pricing {
        Some(pricing) => {
            if let Some(Extension(cache_client)) = cache {
                let _ = cache_client.delete(&keys::pricing(id)).await;
                let _ = cache_client
                    .delete(&keys::product_current_pricing(pricing.product_id))
                    .await;
                let _ = cache_client
                    .delete(&format!("price_history:{}", pricing.product_id))
                    .await;
            }
            Ok(Json(json!({"data": pricing})))
        }
        None => Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Product pricing not found"})),
        )),
    }
}

/// Delete product pricing
pub async fn delete_product_pricing(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let pricing =
        sqlx::query_as::<_, ProductPricing>("SELECT * FROM product_pricing WHERE id = $1")
            .bind(id)
            .fetch_optional(&pool)
            .await
            .map_err(|e| {
                tracing::error!("Failed to fetch product pricing: {:?}", e);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(json!({"error": "Failed to fetch product pricing"})),
                )
            })?;

    let product_id = match pricing {
        Some(p) => p.product_id,
        None => {
            return Err((
                StatusCode::NOT_FOUND,
                Json(json!({"error": "Product pricing not found"})),
            ))
        }
    };

    let result = sqlx::query("DELETE FROM product_pricing WHERE id = $1")
        .bind(id)
        .execute(&pool)
        .await
        .map_err(|e| {
            tracing::error!("Failed to delete product pricing: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": "Failed to delete product pricing"})),
            )
        })?;

    if result.rows_affected() == 0 {
        return Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Product pricing not found"})),
        ));
    }

    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete(&keys::pricing(id)).await;
        let _ = cache_client
            .delete(&keys::product_current_pricing(product_id))
            .await;
        let _ = cache_client
            .delete(&format!("price_history:{}", product_id))
            .await;
    }

    Ok(Json(
        json!({"message": "Product pricing deleted successfully"}),
    ))
}
