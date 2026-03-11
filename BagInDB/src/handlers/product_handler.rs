use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::{IntoResponse, Json},
};
use serde_json::json;
use sqlx::{PgPool, Postgres, QueryBuilder};
use std::time::Duration;
use uuid::Uuid;

use crate::cache::{keys, CacheClient};
use crate::models::{CreateProductRequest, Product, ProductQuery, UpdateProductRequest};

/// Apply product filters to a query builder
/// This function is used by both the main query and count query to avoid duplication
fn apply_product_filters<'a>(query: &mut QueryBuilder<'a, Postgres>, params: &'a ProductQuery) {
    // Basic product filters
    if let Some(category_id) = params.category_id {
        query.push(" AND category_id = ");
        query.push_bind(category_id);
    }

    if let Some(brand_id) = params.brand_id {
        query.push(" AND brand_id = ");
        query.push_bind(brand_id);
    }

    if let Some(is_verified) = params.is_verified {
        query.push(" AND is_verified = ");
        query.push_bind(is_verified);
    }

    // Price filters
    if let Some(price_min) = params.price_min {
        query.push(" AND current_price_min >= ");
        query.push_bind(price_min);
    }

    if let Some(price_max) = params.price_max {
        query.push(" AND current_price_max <= ");
        query.push_bind(price_max);
    }

    if let Some(currency) = &params.currency {
        query.push(" AND current_price_currency = ");
        query.push_bind(currency);
    }

    // Search filter
    if let Some(search) = &params.search {
        let locale = params.locale.clone().unwrap_or_else(|| "ko".to_string());
        query.push(" AND (name->>");
        query.push_bind(locale.clone());
        query.push(" ILIKE ");
        query.push_bind(format!("%{}%", search));
        query.push(" OR description->>");
        query.push_bind(locale);
        query.push(" ILIKE ");
        query.push_bind(format!("%{}%", search));
        query.push(")");
    }

    // Dynamic JSONB spec filters
    // Process all spec_* parameters
    for (key, value) in &params.spec_filters {
        if !key.starts_with("spec_") {
            continue;
        }

        // Remove "spec_" prefix to get the actual field name
        let field_name = &key[5..];

        // Handle different filter types
        if field_name.ends_with("_min") {
            // Range filter: minimum value
            let actual_field = &field_name[..field_name.len() - 4];

            // Determine type based on value
            if let Ok(int_val) = value.parse::<i32>() {
                query.push(format!(" AND (specs->>'{}')", actual_field));
                query.push("::int >= ");
                query.push_bind(int_val);
            } else if let Ok(float_val) = value.parse::<f64>() {
                query.push(format!(" AND (specs->>'{}')", actual_field));
                query.push("::float >= ");
                query.push_bind(float_val);
            }
        } else if field_name.ends_with("_max") {
            // Range filter: maximum value
            let actual_field = &field_name[..field_name.len() - 4];

            if let Ok(int_val) = value.parse::<i32>() {
                query.push(format!(" AND (specs->>'{}')", actual_field));
                query.push("::int <= ");
                query.push_bind(int_val);
            } else if let Ok(float_val) = value.parse::<f64>() {
                query.push(format!(" AND (specs->>'{}')", actual_field));
                query.push("::float <= ");
                query.push_bind(float_val);
            }
        } else if field_name.ends_with("_contains") {
            // Array contains filter
            let actual_field = &field_name[..field_name.len() - 9];
            query.push(format!(" AND specs->'{}' @> ", actual_field));
            query.push_bind(format!("[\"{}\"]", value));
        } else {
            // Equality filter
            // Detect type from value
            if value == "true" || value == "false" {
                // Boolean
                let bool_val = value == "true";
                query.push(format!(" AND (specs->>'{}')", field_name));
                query.push("::boolean = ");
                query.push_bind(bool_val);
            } else if value.parse::<i32>().is_ok() {
                // Integer
                let int_val = value.parse::<i32>().unwrap();
                query.push(format!(" AND (specs->>'{}')", field_name));
                query.push("::int = ");
                query.push_bind(int_val);
            } else if value.parse::<f64>().is_ok() {
                // Float
                let float_val = value.parse::<f64>().unwrap();
                query.push(format!(" AND (specs->>'{}')", field_name));
                query.push("::float = ");
                query.push_bind(float_val);
            } else {
                // String
                query.push(format!(" AND specs->>'{}' = ", field_name));
                query.push_bind(value);
            }
        }
    }
}

pub async fn list_products(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Query(params): Query<ProductQuery>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    tracing::info!("list_products called with params: {:?}", params);

    let limit = params.limit.unwrap_or(20).min(100);
    let page = params.page.unwrap_or(0);
    let offset = page * limit;

    // 캐시 키 생성 (모든 필터 포함)
    let filter_hash = params.to_cache_hash();
    let cache_key = keys::products_list(&filter_hash, page);

    // 캐시에서 먼저 확인
    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached_response)) = cache_client.get::<serde_json::Value>(&cache_key).await {
            tracing::info!("Cache HIT for key: {}", cache_key);
            return Ok(Json(cached_response));
        }
        tracing::info!("Cache MISS for key: {}", cache_key);
    }

    // Build query using JSONB specs field with optimized filtering
    let mut query_builder = sqlx::QueryBuilder::new("SELECT * FROM products WHERE 1=1");

    // Apply all filters using shared function
    apply_product_filters(&mut query_builder, &params);

    // Sorting
    let sort_by = params.sort_by.as_deref().unwrap_or("created_at");
    let order = params.order.as_deref().unwrap_or("desc");

    // Validate sort_by to prevent SQL injection
    let safe_sort_by = match sort_by {
        "name" => "name",
        "price" => "current_price_min",
        "created_at" => "created_at",
        "updated_at" => "updated_at",
        "release_date" => "release_date",
        "view_count" => "view_count",
        _ => "created_at",
    };

    // Validate order
    let safe_order = match order.to_lowercase().as_str() {
        "asc" => "ASC",
        "desc" => "DESC",
        _ => "DESC",
    };

    query_builder.push(format!(" ORDER BY {} {} LIMIT ", safe_sort_by, safe_order));
    query_builder.push_bind(limit);
    query_builder.push(" OFFSET ");
    query_builder.push_bind(offset);

    let sql = query_builder.sql();
    tracing::info!("Executing SQL: {}", sql);

    let products: Vec<Product> = query_builder
        .build_query_as()
        .fetch_all(&pool)
        .await
        .map_err(|e| {
            tracing::error!("Database error in list_products: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": e.to_string()})),
            )
        })?;

    // Total count query - reuse same WHERE clause construction
    let total_count: i64 = {
        let mut count_query =
            sqlx::QueryBuilder::new("SELECT COUNT(*)::bigint FROM products WHERE 1=1");

        // Apply same filters to count query
        apply_product_filters(&mut count_query, &params);

        count_query
            .build_query_scalar()
            .fetch_one(&pool)
            .await
            .unwrap_or(0)
    };

    let response = json!({
        "data": products,
        "page": page,
        "limit": limit,
        "total": total_count,
        "total_pages": (total_count as f64 / limit as f64).ceil() as i64
    });

    // 캐시에 저장 (5분 TTL)
    if let Some(Extension(cache_client)) = cache {
        if let Err(e) = cache_client
            .set(&cache_key, &response, Duration::from_secs(300))
            .await
        {
            tracing::warn!("Failed to cache products: {:?}", e);
        } else {
            tracing::info!("Cached products with key: {}", cache_key);
        }
    }

    Ok(Json(response))
}

pub async fn get_product(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    tracing::info!("get_product called with id: {}", id);

    // 캐시 키 생성
    let cache_key = keys::product(id);

    // 캐시에서 먼저 확인
    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached_product)) = cache_client.get::<Product>(&cache_key).await {
            tracing::info!("Cache HIT for product: {}", id);
            return Ok(Json(json!({"data": cached_product, "cached": true})));
        }
        tracing::info!("Cache MISS for product: {}", id);
    }

    let product = sqlx::query_as::<_, Product>("SELECT * FROM products WHERE id = $1")
        .bind(id)
        .fetch_optional(&pool)
        .await
        .map_err(|e| {
            tracing::error!("Database error in get_product: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": e.to_string()})),
            )
        })?;

    match product {
        Some(product) => {
            // 캐시에 저장 (15분 TTL)
            if let Some(Extension(cache_client)) = cache {
                let _ = cache_client
                    .set(&cache_key, &product, Duration::from_secs(900))
                    .await;
            }
            Ok(Json(json!({"data": product})))
        }
        None => Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Product not found"})),
        )),
    }
}

pub async fn create_product(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Json(req): Json<CreateProductRequest>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let product = sqlx::query_as::<_, Product>(
        r#"
        INSERT INTO products (
            slug, category_id, brand_id, name, description, model_number,
            identifiers, image_url, images, manufacturer_country, release_date,
            discontinued_date, is_verified, available_locales, default_locale,
            dimensions, weight, power_watts, voltage, specs,
            current_price_min, current_price_max, current_price_currency,
            purchase_links, official_url
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25)
        RETURNING *
        "#,
    )
    .bind(&req.slug)
    .bind(&req.category_id)
    .bind(&req.brand_id)
    .bind(&req.name)
    .bind(&req.description)
    .bind(&req.model_number)
    .bind(&req.identifiers)
    .bind(&req.image_url)
    .bind(&req.images)
    .bind(&req.manufacturer_country)
    .bind(&req.release_date)
    .bind(&req.discontinued_date)
    .bind(req.is_verified.unwrap_or(false))
    .bind(req.available_locales.unwrap_or_else(|| vec!["ko".to_string(), "en".to_string()]))
    .bind(req.default_locale.unwrap_or_else(|| "en".to_string()))
    .bind(&req.dimensions)
    .bind(&req.weight)
    .bind(&req.power_watts)
    .bind(&req.voltage)
    .bind(&req.specs)
    .bind(&req.current_price_min)
    .bind(&req.current_price_max)
    .bind(&req.current_price_currency)
    .bind(&req.purchase_links)
    .bind(&req.official_url)
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
        let _ = cache_client.delete_pattern("products:*").await;
        tracing::info!("Invalidated products cache after create");
    }

    Ok((StatusCode::CREATED, Json(json!({"data": product}))))
}

pub async fn update_product(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
    Json(req): Json<UpdateProductRequest>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let mut query_builder = sqlx::QueryBuilder::new("UPDATE products SET updated_at = NOW()");
    let mut has_fields = false;

    if let Some(slug) = &req.slug {
        query_builder.push(", slug = ");
        query_builder.push_bind(slug);
        has_fields = true;
    }

    if let Some(name) = &req.name {
        query_builder.push(", name = ");
        query_builder.push_bind(name);
        has_fields = true;
    }

    if let Some(category_id) = &req.category_id {
        query_builder.push(", category_id = ");
        query_builder.push_bind(category_id);
        has_fields = true;
    }

    if let Some(brand_id) = &req.brand_id {
        query_builder.push(", brand_id = ");
        query_builder.push_bind(brand_id);
        has_fields = true;
    }

    if let Some(specs) = &req.specs {
        query_builder.push(", specs = ");
        query_builder.push_bind(specs);
        has_fields = true;
    }

    if let Some(dimensions) = &req.dimensions {
        query_builder.push(", dimensions = ");
        query_builder.push_bind(dimensions);
        has_fields = true;
    }

    if let Some(weight) = &req.weight {
        query_builder.push(", weight = ");
        query_builder.push_bind(weight);
        has_fields = true;
    }

    if let Some(power_watts) = &req.power_watts {
        query_builder.push(", power_watts = ");
        query_builder.push_bind(power_watts);
        has_fields = true;
    }

    if let Some(voltage) = &req.voltage {
        query_builder.push(", voltage = ");
        query_builder.push_bind(voltage);
        has_fields = true;
    }

    if let Some(price_min) = &req.current_price_min {
        query_builder.push(", current_price_min = ");
        query_builder.push_bind(price_min);
        has_fields = true;
    }

    if let Some(price_max) = &req.current_price_max {
        query_builder.push(", current_price_max = ");
        query_builder.push_bind(price_max);
        has_fields = true;
    }

    if let Some(currency) = &req.current_price_currency {
        query_builder.push(", current_price_currency = ");
        query_builder.push_bind(currency);
        has_fields = true;
    }

    if let Some(purchase_links) = &req.purchase_links {
        query_builder.push(", purchase_links = ");
        query_builder.push_bind(purchase_links);
        has_fields = true;
    }

    if let Some(official_url) = &req.official_url {
        query_builder.push(", official_url = ");
        query_builder.push_bind(official_url);
        has_fields = true;
    }

    if let Some(image_url) = &req.image_url {
        query_builder.push(", image_url = ");
        query_builder.push_bind(image_url);
        has_fields = true;
    }

    if let Some(images) = &req.images {
        query_builder.push(", images = ");
        query_builder.push_bind(images);
        has_fields = true;
    }

    if let Some(description) = &req.description {
        query_builder.push(", description = ");
        query_builder.push_bind(description);
        has_fields = true;
    }

    if let Some(model_number) = &req.model_number {
        query_builder.push(", model_number = ");
        query_builder.push_bind(model_number);
        has_fields = true;
    }

    if let Some(is_verified) = &req.is_verified {
        query_builder.push(", is_verified = ");
        query_builder.push_bind(is_verified);
        has_fields = true;
    }

    if !has_fields {
        return Err((
            StatusCode::BAD_REQUEST,
            Json(json!({"error": "No fields to update"})),
        ));
    }

    query_builder.push(" WHERE id = ");
    query_builder.push_bind(id);
    query_builder.push(" RETURNING *");

    let product: Product = query_builder
        .build_query_as()
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
        let _ = cache_client.delete(&keys::product(id)).await;
        let _ = cache_client.delete_pattern("products:*").await;
        tracing::info!("Invalidated product cache after update: {}", id);
    }

    Ok(Json(json!({"data": product})))
}

pub async fn delete_product(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let result = sqlx::query("DELETE FROM products WHERE id = $1")
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
            Json(json!({"error": "Product not found"})),
        ));
    }

    // 캐시 무효화
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete(&keys::product(id)).await;
        let _ = cache_client.delete_pattern("products:*").await;
        tracing::info!("Invalidated product cache after delete: {}", id);
    }

    Ok((StatusCode::NO_CONTENT, Json(json!({}))))
}

/// Get product specs - now specs are directly in the product.specs JSONB field
pub async fn get_product_specs(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    tracing::info!("get_product_specs called with product id: {}", id);

    // 캐시 키 생성
    let cache_key = keys::product_specs(id);

    // 캐시에서 먼저 확인
    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached_spec)) = cache_client.get::<serde_json::Value>(&cache_key).await {
            tracing::info!("Cache HIT for specs key: {}", cache_key);
            return Ok(Json(json!({
                "data": cached_spec,
                "cached": true
            })));
        }
        tracing::info!("Cache MISS for specs key: {}", cache_key);
    }

    // Fetch the product with its specs
    let product = sqlx::query_as::<_, Product>("SELECT * FROM products WHERE id = $1")
        .bind(id)
        .fetch_optional(&pool)
        .await
        .map_err(|e| {
            tracing::error!("Database error in get_product_specs: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": e.to_string()})),
            )
        })?;

    match product {
        Some(product) => {
            let specs = product.specs.unwrap_or(serde_json::json!({}));

            // 캐시에 저장 (15분 TTL)
            if let Some(Extension(cache_client)) = cache {
                let _ = cache_client
                    .set(&cache_key, &specs, Duration::from_secs(900))
                    .await;
                tracing::info!("Cached specs for key: {}", cache_key);
            }

            Ok(Json(json!({"data": specs})))
        }
        None => Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "Product not found"})),
        )),
    }
}
