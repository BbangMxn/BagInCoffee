mod cache;
mod db;
mod handlers;
mod middleware;
mod models;
mod routes;

use anyhow::Result;
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> Result<()> {
    // Load environment variables
    dotenv::dotenv().ok();

    // Initialize tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "bag_in_db=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Starting BagInDB server...");

    // Create database connection pool
    let pool = match db::create_pool().await {
        Ok(pool) => {
            tracing::info!("Database connection pool created");
            pool
        }
        Err(e) => {
            tracing::error!("Failed to create database pool: {:?}", e);
            tracing::error!(
                "DATABASE_URL env var: {}",
                std::env::var("DATABASE_URL").unwrap_or_else(|_| "NOT SET".to_string())
            );
            return Err(e);
        }
    };

    // Create Redis cache client
    let redis_url = std::env::var("REDIS_URL").unwrap_or_else(|_| {
        tracing::warn!("REDIS_URL not set, caching will be disabled");
        String::new()
    });

    let cache = if !redis_url.is_empty() {
        match cache::CacheClient::new(&redis_url).await {
            Ok(client) => {
                tracing::info!("Redis cache initialized");
                // 서버 시작 시 캐시 초기화 (오래된 캐시 데이터 제거)
                if let Err(e) = client.flush_all().await {
                    tracing::warn!("Failed to flush cache on startup: {:?}", e);
                }
                Some(client)
            }
            Err(e) => {
                tracing::error!("Failed to connect to Redis: {:?}", e);
                tracing::warn!("Continuing without cache");
                None
            }
        }
    } else {
        None
    };

    // Configure CORS
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // Create routes with authentication and cache
    let app = routes::create_routes(pool, cache)
        .layer(cors)
        .layer(tower_http::trace::TraceLayer::new_for_http());

    // Get server configuration
    let host = std::env::var("SERVER_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());

    // Railway uses PORT env var, fallback to SERVER_PORT or 8080
    let port = std::env::var("PORT")
        .or_else(|_| std::env::var("SERVER_PORT"))
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()?;

    let addr = SocketAddr::from((host.parse::<std::net::IpAddr>()?, port));

    tracing::info!("Server will listen on {}", addr);
    tracing::info!("Environment: HOST={}, PORT={}", host, port);

    // Start server
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
