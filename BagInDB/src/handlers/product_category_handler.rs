use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::{IntoResponse, Json},
};
use serde_json::json;
use sqlx::PgPool;
use std::time::Duration;
use uuid::Uuid;

use crate::cache::{keys, CacheClient};
use crate::models::{CreateProductCategoryRequest, ProductCategory, ProductCategoryQuery};

pub async fn list_product_categories(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Query(params): Query<ProductCategoryQuery>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    tracing::info!("list_product_categories called with params: {:?}", params);

    // 캐시 확인
    let cache_key = keys::categories();
    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached)) = cache_client.get::<Vec<ProductCategory>>(&cache_key).await {
            tracing::info!("Cache HIT for categories");
            return Ok(Json(json!({"data": cached})));
        }
        tracing::info!("Cache MISS for categories");
    }

    let limit = params.limit.unwrap_or(100).min(200);
    let offset = params.page.unwrap_or(0) * limit;

    let mut query_builder = sqlx::QueryBuilder::new("SELECT * FROM product_categories WHERE 1=1");

    if let Some(is_active) = params.is_active {
        query_builder.push(" AND is_active = ");
        query_builder.push_bind(is_active);
    }

    if let Some(parent_id) = params.parent_id {
        query_builder.push(" AND parent_id = ");
        query_builder.push_bind(parent_id);
    }

    if let Some(level) = params.level {
        query_builder.push(" AND level = ");
        query_builder.push_bind(level);
    }

    if let Some(search) = params.search {
        let locale = params.locale.unwrap_or_else(|| "ko".to_string());
        query_builder.push(" AND name->>");
        query_builder.push_bind(locale);
        query_builder.push(" ILIKE ");
        query_builder.push_bind(format!("%{}%", search));
    }

    query_builder.push(" ORDER BY display_order ASC, level ASC LIMIT ");
    query_builder.push_bind(limit);
    query_builder.push(" OFFSET ");
    query_builder.push_bind(offset);

    let categories: Vec<ProductCategory> = query_builder
        .build_query_as()
        .fetch_all(&pool)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": e.to_string()})),
            )
        })?;

    // 캐시에 저장 (10분 TTL - 카테고리는 자주 변경되지 않음)
    if let Some(Extension(cache_client)) = cache {
        if let Err(e) = cache_client
            .set(&cache_key, &categories, Duration::from_secs(600))
            .await
        {
            tracing::warn!("Failed to cache categories: {:?}", e);
        } else {
            tracing::info!("Cached categories");
        }
    }

    Ok(Json(json!({
        "data": categories,
        "page": params.page.unwrap_or(0),
        "limit": limit
    })))
}

pub async fn get_product_category(
    State(pool): State<PgPool>,
    _cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    // 개별 카테고리는 전체 캐시에서 찾거나 DB 조회
    let category =
        sqlx::query_as::<_, ProductCategory>("SELECT * FROM product_categories WHERE id = $1")
            .bind(id)
            .fetch_optional(&pool)
            .await
            .map_err(|e| {
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(json!({"error": e.to_string()})),
                )
            })?;

    match category {
        Some(category) => Ok(Json(json!({"data": category}))),
        None => Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Category not found"})),
        )),
    }
}

pub async fn create_product_category(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Json(req): Json<CreateProductCategoryRequest>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let category = sqlx::query_as::<_, ProductCategory>(
        r#"
        INSERT INTO product_categories (
            slug, parent_id, level, path, name, description, spec_table_name,
            icon_url, image_url, display_order, is_active
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
        "#,
    )
    .bind(&req.slug)
    .bind(&req.parent_id)
    .bind(req.level.unwrap_or(0))
    .bind(&req.path)
    .bind(&req.name)
    .bind(&req.description)
    .bind(&req.spec_table_name)
    .bind(&req.icon_url)
    .bind(&req.image_url)
    .bind(req.display_order.unwrap_or(0))
    .bind(req.is_active.unwrap_or(true))
    .fetch_one(&pool)
    .await
    .map_err(|e| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": e.to_string()})),
        )
    })?;

    // 캐시 무효화
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete(&keys::categories()).await;
        tracing::info!("Invalidated categories cache after create");
    }

    Ok((StatusCode::CREATED, Json(json!({"data": category}))))
}

pub async fn delete_product_category(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let result = sqlx::query("DELETE FROM product_categories WHERE id = $1")
        .bind(id)
        .execute(&pool)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": e.to_string()})),
            )
        })?;

    if result.rows_affected() == 0 {
        return Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Category not found"})),
        ));
    }

    // 캐시 무효화
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete(&keys::categories()).await;
        tracing::info!("Invalidated categories cache after delete");
    }

    Ok((StatusCode::NO_CONTENT, Json(json!({}))))
}
