use anyhow::Result;
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;
use std::env;
use std::time::Duration;

pub async fn create_pool() -> Result<PgPool> {
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set in .env file");

    // Optimized connection pool settings for production
    let pool = PgPoolOptions::new()
        // Maximum number of connections in the pool
        // Adjust based on your workload and Supabase plan limits
        .max_connections(20)
        // Minimum idle connections to maintain for fast response times
        .min_connections(5)
        // Maximum lifetime of a connection (prevents stale connections)
        .max_lifetime(Duration::from_secs(30 * 60)) // 30 minutes
        // Maximum idle time before connection is closed
        .idle_timeout(Duration::from_secs(10 * 60)) // 10 minutes
        // Connection timeout
        .acquire_timeout(Duration::from_secs(5))
        // Test connections before use to avoid errors from closed connections
        .test_before_acquire(true)
        .connect(&database_url)
        .await?;

    tracing::info!("Database pool created with max_connections=20, min_connections=5");

    Ok(pool)
}
