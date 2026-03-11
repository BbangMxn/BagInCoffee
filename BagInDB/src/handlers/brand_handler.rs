use axum::{
    extract::{Extension, Path, Query, State},
    http::StatusCode,
    response::{IntoResponse, Json as AxumJson},
};
use serde_json::json;
use sqlx::{types::Json, PgPool};

use uuid::Uuid;

use crate::cache::CacheClient;
use crate::models::{Brand, BrandFilter, CreateBrandRequest, UpdateBrandRequest};

/// Apply brand filters to a query builder
fn apply_brand_filters<'a>(
    query: &mut sqlx::QueryBuilder<'a, sqlx::Postgres>,
    params: &'a BrandFilter,
) {
    if let Some(is_active) = params.is_active {
        query.push(" AND is_active = ");
        query.push_bind(is_active);
    }

    if let Some(featured) = params.featured {
        query.push(" AND featured = ");
        query.push_bind(featured);
    }

    if let Some(verified) = params.verified {
        query.push(" AND verified = ");
        query.push_bind(verified);
    }

    if let Some(country) = &params.country {
        query.push(" AND country = ");
        query.push_bind(country);
    }

    if let Some(slug) = &params.slug {
        query.push(" AND slug = ");
        query.push_bind(slug);
    }

    if let Some(search) = &params.search {
        query.push(" AND (name::text ILIKE ");
        query.push_bind(format!("%{}%", search));
        query.push(" OR description::text ILIKE ");
        query.push_bind(format!("%{}%", search));
        query.push(")");
    }
}

pub async fn list_brands(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Query(params): Query<BrandFilter>,
) -> Result<impl IntoResponse, (StatusCode, AxumJson<serde_json::Value>)> {
    tracing::info!("list_brands called with params: {:?}", params);

    let limit = params.limit.unwrap_or(20).min(100);
    let page = params.page.unwrap_or(0);
    let offset = params.offset.unwrap_or(page * limit);

    // 캐시 키 생성 (필터 포함)
    let cache_key = format!(
        "brands:page={}:limit={}:country={:?}:search={:?}",
        page, limit, params.country, params.search
    );

    // 캐시에서 먼저 확인
    if let Some(Extension(cache_client)) = &cache {
        if let Ok(Some(cached_response)) = cache_client.get::<serde_json::Value>(&cache_key).await {
            tracing::info!("Cache HIT for key: {}", cache_key);
            return Ok(AxumJson(cached_response));
        }
        tracing::info!("Cache MISS for key: {}", cache_key);
    }

    // Build main query
    let mut query_builder = sqlx::QueryBuilder::new("SELECT * FROM brands WHERE 1=1");
    apply_brand_filters(&mut query_builder, &params);

    query_builder.push(" ORDER BY created_at DESC LIMIT ");
    query_builder.push_bind(limit);
    query_builder.push(" OFFSET ");
    query_builder.push_bind(offset);

    let brands: Vec<Brand> = query_builder
        .build_query_as()
        .fetch_all(&pool)
        .await
        .map_err(|e| {
            tracing::error!("Database error in list_brands: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                AxumJson(json!({"error": e.to_string()})),
            )
        })?;

    // Total count query
    let total_count: i64 = {
        let mut count_query =
            sqlx::QueryBuilder::new("SELECT COUNT(*)::bigint FROM brands WHERE 1=1");
        apply_brand_filters(&mut count_query, &params);

        count_query
            .build_query_scalar()
            .fetch_one(&pool)
            .await
            .unwrap_or(0)
    };

    let response = json!({
        "data": brands,
        "page": page,
        "limit": limit,
        "total": total_count,
        "total_pages": (total_count as f64 / limit as f64).ceil() as i64
    });

    // 캐시에 저장 (10분 TTL)
    if let Some(Extension(cache_client)) = cache {
        if let Err(e) = cache_client
            .set(&cache_key, &response, std::time::Duration::from_secs(600))
            .await
        {
            tracing::warn!("Failed to cache brands: {:?}", e);
        }
    }

    Ok(AxumJson(response))
}

pub async fn get_brand(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, AxumJson<serde_json::Value>)> {
    let brand = sqlx::query_as::<_, Brand>("SELECT * FROM brands WHERE id = $1")
        .bind(id)
        .fetch_optional(&pool)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                AxumJson(json!({"error": e.to_string()})),
            )
        })?;

    match brand {
        Some(brand) => Ok(AxumJson(json!({"data": brand}))),
        None => Err((
            StatusCode::NOT_FOUND,
            AxumJson(json!({"error": "Brand not found"})),
        )),
    }
}

pub async fn create_brand(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    AxumJson(req): AxumJson<CreateBrandRequest>,
) -> Result<impl IntoResponse, (StatusCode, AxumJson<serde_json::Value>)> {
    let brand = sqlx::query_as::<_, Brand>(
        r#"
        INSERT INTO brands (
            slug, name, description, headquarters, logo_url, images,
            website, country, founded_date, specialization, is_active,
            featured, verified
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        RETURNING *
        "#,
    )
    .bind(&req.slug)
    .bind(Json(&req.name))
    .bind(req.description.as_ref().map(Json))
    .bind(req.headquarters.as_ref().map(Json))
    .bind(&req.logo_url)
    .bind(&req.images)
    .bind(&req.website)
    .bind(&req.country)
    .bind(&req.founded_date)
    .bind(&req.specialization)
    .bind(req.is_active)
    .bind(req.featured)
    .bind(req.verified)
    .fetch_one(&pool)
    .await
    .map_err(|e| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            AxumJson(json!({"error": e.to_string()})),
        )
    })?;

    // 캐시 무효화 (모든 브랜드 관련 캐시)
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete_pattern("brands:*").await;
        tracing::info!("Invalidated brands cache after create");
    }

    Ok((StatusCode::CREATED, AxumJson(json!({"data": brand}))))
}

pub async fn update_brand(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
    AxumJson(req): AxumJson<UpdateBrandRequest>,
) -> Result<impl IntoResponse, (StatusCode, AxumJson<serde_json::Value>)> {
    let mut query_builder = sqlx::QueryBuilder::new("UPDATE brands SET updated_at = NOW()");
    let mut has_fields = false;

    if let Some(slug) = &req.slug {
        query_builder.push(", slug = ");
        query_builder.push_bind(slug);
        has_fields = true;
    }

    if let Some(name) = &req.name {
        query_builder.push(", name = ");
        query_builder.push_bind(Json(name));
        has_fields = true;
    }

    if let Some(description) = &req.description {
        query_builder.push(", description = ");
        query_builder.push_bind(Json(description));
        has_fields = true;
    }

    if let Some(headquarters) = &req.headquarters {
        query_builder.push(", headquarters = ");
        query_builder.push_bind(Json(headquarters));
        has_fields = true;
    }

    if let Some(logo_url) = &req.logo_url {
        query_builder.push(", logo_url = ");
        query_builder.push_bind(logo_url);
        has_fields = true;
    }

    if let Some(images) = &req.images {
        query_builder.push(", images = ");
        query_builder.push_bind(images);
        has_fields = true;
    }

    if let Some(website) = &req.website {
        query_builder.push(", website = ");
        query_builder.push_bind(website);
        has_fields = true;
    }

    if let Some(country) = &req.country {
        query_builder.push(", country = ");
        query_builder.push_bind(country);
        has_fields = true;
    }

    if let Some(founded_date) = &req.founded_date {
        query_builder.push(", founded_date = ");
        query_builder.push_bind(founded_date);
        has_fields = true;
    }

    if let Some(specialization) = &req.specialization {
        query_builder.push(", specialization = ");
        query_builder.push_bind(specialization);
        has_fields = true;
    }

    if let Some(is_active) = req.is_active {
        query_builder.push(", is_active = ");
        query_builder.push_bind(is_active);
        has_fields = true;
    }

    if let Some(featured) = req.featured {
        query_builder.push(", featured = ");
        query_builder.push_bind(featured);
        has_fields = true;
    }

    if let Some(verified) = req.verified {
        query_builder.push(", verified = ");
        query_builder.push_bind(verified);
        has_fields = true;
    }

    if !has_fields {
        return Err((
            StatusCode::BAD_REQUEST,
            AxumJson(json!({"error": "No fields to update"})),
        ));
    }

    query_builder.push(" WHERE id = ");
    query_builder.push_bind(id);
    query_builder.push(" RETURNING *");

    let brand: Brand = query_builder
        .build_query_as()
        .fetch_one(&pool)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                AxumJson(json!({"error": e.to_string()})),
            )
        })?;

    // 캐시 무효화 (모든 브랜드 관련 캐시)
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete_pattern("brands:*").await;
        tracing::info!("Invalidated brands cache after update");
    }

    Ok(AxumJson(json!({"data": brand})))
}

pub async fn delete_brand(
    State(pool): State<PgPool>,
    cache: Option<Extension<CacheClient>>,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, (StatusCode, AxumJson<serde_json::Value>)> {
    let result = sqlx::query("DELETE FROM brands WHERE id = $1")
        .bind(id)
        .execute(&pool)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                AxumJson(json!({"error": e.to_string()})),
            )
        })?;

    if result.rows_affected() == 0 {
        return Err((
            StatusCode::NOT_FOUND,
            AxumJson(json!({"error": "Brand not found"})),
        ));
    }

    // 캐시 무효화 (모든 브랜드 관련 캐시)
    if let Some(Extension(cache_client)) = cache {
        let _ = cache_client.delete_pattern("brands:*").await;
        tracing::info!("Invalidated brands cache after delete");
    }

    Ok((StatusCode::NO_CONTENT, AxumJson(json!({}))))
}
