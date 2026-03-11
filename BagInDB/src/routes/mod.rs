use crate::cache::CacheClient;
use axum::{
    extract::Request,
    middleware::{from_fn, Next},
    response::Response,
    routing::{delete, get, post, put},
    Router,
};
use sqlx::PgPool;

use crate::handlers::{
    // Cache handlers
    clear_all_cache,
    clear_categories_cache,
    clear_products_cache,
    // Brand handlers
    create_brand,
    // Product handlers (with unified JSONB specs)
    create_product,
    // Product category handlers
    create_product_category,
    // Product pricing handlers
    create_product_pricing,
    delete_brand,
    delete_product,
    delete_product_category,
    delete_product_pricing,
    get_brand,
    get_current_pricing_for_product,
    get_price_history_for_product,
    get_product,
    get_product_category,
    get_product_pricing,
    get_product_specs,
    list_brands,
    list_product_categories,
    list_product_pricing,
    list_products,
    update_brand,
    update_product,
    update_product_pricing,
};
use crate::middleware::{admin_middleware, auth_middleware, moderator_middleware};

pub fn create_routes(pool: PgPool, cache: Option<CacheClient>) -> Router {
    let pool_clone = pool.clone();

    // Public routes (READ-only, no authentication required)
    let public_routes = Router::new()
        // Health check
        .route("/health", get(health_check))
        // Cache management routes (temporary public for testing)
        .route(
            "/api/cache/categories/clear",
            delete(clear_categories_cache),
        )
        .route("/api/cache/products/clear", delete(clear_products_cache))
        .route("/api/cache/all/clear", delete(clear_all_cache))
        // Brand routes (read-only)
        .route("/api/brands", get(list_brands))
        .route("/api/brands/:id", get(get_brand))
        // Product Category routes (read-only)
        .route("/api/categories", get(list_product_categories))
        .route("/api/categories/:id", get(get_product_category))
        // Product routes (read-only) - Unified JSONB specs
        .route("/api/products", get(list_products))
        .route("/api/products/:id", get(get_product))
        .route("/api/products/:id/specs", get(get_product_specs))
        // Product pricing routes (read-only)
        .route("/api/pricing", get(list_product_pricing))
        .route("/api/pricing/:id", get(get_product_pricing))
        .route(
            "/api/products/:product_id/pricing/current",
            get(get_current_pricing_for_product),
        )
        .route(
            "/api/products/:product_id/pricing/history",
            get(get_price_history_for_product),
        );

    // Admin-only routes (WRITE operations for critical data)
    // Requires both auth_middleware and admin_middleware
    let admin_routes = Router::new()
        // Cache management routes (admin only)
        .route(
            "/api/admin/cache/categories",
            delete(clear_categories_cache),
        )
        .route("/api/admin/cache/products", delete(clear_products_cache))
        .route("/api/admin/cache/all", delete(clear_all_cache))
        // Brand routes (admin only - critical data)
        .route("/api/brands", post(create_brand))
        .route("/api/brands/:id", put(update_brand).delete(delete_brand))
        // Product Category routes (admin only - critical data)
        .route("/api/categories", post(create_product_category))
        .route("/api/categories/:id", delete(delete_product_category))
        // Product deletion (admin only)
        .route("/api/products/:id", delete(delete_product))
        // Pricing deletion (admin only)
        .route("/api/pricing/:id", delete(delete_product_pricing))
        // Apply middlewares: Note - layers are applied in reverse order!
        // This means: admin_middleware runs first, then auth_middleware, then inject_pool
        .layer(from_fn(admin_middleware))
        .layer(from_fn(auth_middleware))
        .layer(from_fn(move |req, next| {
            inject_pool(req, next, pool_clone.clone())
        }));

    let pool_clone2 = pool.clone();

    // Moderator routes (product and pricing management)
    // Requires both auth_middleware and moderator_middleware
    let moderator_routes = Router::new()
        // Product routes (moderators can create and update)
        .route("/api/products", post(create_product))
        .route("/api/products/:id", put(update_product))
        // Product pricing routes (moderators can create and update)
        .route("/api/pricing", post(create_product_pricing))
        .route("/api/pricing/:id", put(update_product_pricing))
        // Apply middlewares: Note - layers are applied in reverse order!
        // This means: moderator_middleware runs first, then auth_middleware, then inject_pool
        .layer(from_fn(moderator_middleware))
        .layer(from_fn(auth_middleware))
        .layer(from_fn(move |req, next| {
            inject_pool(req, next, pool_clone2.clone())
        }));

    // Combine public, moderator and admin routes with cache extension
    let app = public_routes.merge(moderator_routes).merge(admin_routes);

    let app = if let Some(cache) = cache {
        app.layer(axum::middleware::from_fn(
            move |mut req: Request, next: Next| {
                let cache = cache.clone();
                async move {
                    req.extensions_mut().insert(cache);
                    next.run(req).await
                }
            },
        ))
    } else {
        app
    };

    app.with_state(pool)
}

/// Middleware to inject database pool into request extensions
async fn inject_pool(mut request: Request, next: Next, pool: PgPool) -> Response {
    request.extensions_mut().insert(pool);
    next.run(request).await
}

async fn health_check() -> &'static str {
    "OK"
}
