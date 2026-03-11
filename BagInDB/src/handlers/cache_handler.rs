use axum::{
    extract::Extension,
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;

use crate::cache::{keys, CacheClient};

/// Clear all categories cache
pub async fn clear_categories_cache(Extension(cache_client): Extension<CacheClient>) -> Response {
    match cache_client.delete(&keys::categories()).await {
        Ok(_) => {
            tracing::info!("Categories cache cleared successfully");
            (
                StatusCode::OK,
                Json(json!({
                    "message": "Categories cache cleared successfully"
                })),
            )
                .into_response()
        }
        Err(e) => {
            tracing::error!("Failed to clear categories cache: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({
                    "error": "Failed to clear cache"
                })),
            )
                .into_response()
        }
    }
}

/// Clear all products cache
pub async fn clear_products_cache(Extension(cache_client): Extension<CacheClient>) -> Response {
    // Delete all keys matching "products:*"
    match cache_client.delete_pattern("products:*").await {
        Ok(_) => {
            tracing::info!("Products cache cleared successfully");
            (
                StatusCode::OK,
                Json(json!({
                    "message": "Products cache cleared successfully"
                })),
            )
                .into_response()
        }
        Err(e) => {
            tracing::error!("Failed to clear products cache: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({
                    "error": "Failed to clear cache"
                })),
            )
                .into_response()
        }
    }
}

/// Clear all cache
pub async fn clear_all_cache(Extension(cache_client): Extension<CacheClient>) -> Response {
    match cache_client.delete_pattern("*").await {
        Ok(_) => {
            tracing::info!("All cache cleared successfully");
            (
                StatusCode::OK,
                Json(json!({
                    "message": "All cache cleared successfully"
                })),
            )
                .into_response()
        }
        Err(e) => {
            tracing::error!("Failed to clear all cache: {:?}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({
                    "error": "Failed to clear cache"
                })),
            )
                .into_response()
        }
    }
}
