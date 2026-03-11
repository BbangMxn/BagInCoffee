use axum::{
    extract::Request,
    http::{header, StatusCode},
    middleware::Next,
    response::Response,
};
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use uuid::Uuid;

/// Supabase JWT Claims
#[derive(Debug, Serialize, Deserialize)]
pub struct SupabaseClaims {
    pub sub: String,           // user_id (UUID)
    pub email: Option<String>, // user email
    pub role: Option<String>,  // user role
    pub aud: String,           // audience
    pub exp: usize,            // expiration time
    pub iat: usize,            // issued at
}

/// Authentication middleware
pub async fn auth_middleware(mut request: Request, next: Next) -> Result<Response, StatusCode> {
    // Get Authorization header
    let auth_header = request
        .headers()
        .get(header::AUTHORIZATION)
        .and_then(|h| h.to_str().ok())
        .ok_or_else(|| {
            tracing::warn!("Missing Authorization header");
            StatusCode::UNAUTHORIZED
        })?;

    // Extract Bearer token
    let token = auth_header.strip_prefix("Bearer ").ok_or_else(|| {
        tracing::warn!("Invalid Authorization header format");
        StatusCode::UNAUTHORIZED
    })?;

    // Verify token
    let user_id = verify_supabase_token(token).map_err(|e| {
        tracing::error!(error = %e, "Token verification failed");
        StatusCode::UNAUTHORIZED
    })?;

    // Inject user_id into request extensions
    request.extensions_mut().insert(user_id);

    tracing::debug!(user_id = %user_id, "User authenticated successfully");

    // Proceed to next middleware/handler
    Ok(next.run(request).await)
}

/// Verify Supabase JWT token
fn verify_supabase_token(token: &str) -> Result<Uuid, String> {
    // Get JWT secret from environment
    let jwt_secret = std::env::var("SUPABASE_JWT_SECRET")
        .map_err(|_| "SUPABASE_JWT_SECRET not set in environment".to_string())?;

    // JWT validation settings
    let mut validation = Validation::new(Algorithm::HS256);
    validation.set_audience(&["authenticated"]); // Supabase default audience
    validation.validate_exp = true; // Validate expiration time

    // Decode and verify token
    let token_data = decode::<SupabaseClaims>(
        token,
        &DecodingKey::from_secret(jwt_secret.as_bytes()),
        &validation,
    )
    .map_err(|e| format!("Failed to decode token: {}", e))?;

    // Parse user_id (sub) as UUID
    let user_id = Uuid::parse_str(&token_data.claims.sub)
        .map_err(|e| format!("Invalid user_id format: {}", e))?;

    tracing::debug!(
        user_id = %user_id,
        email = ?token_data.claims.email,
        role = ?token_data.claims.role,
        "Token verified successfully"
    );

    Ok(user_id)
}

/// Admin middleware - requires auth_middleware to run first
pub async fn admin_middleware(request: Request, next: Next) -> Result<Response, StatusCode> {
    // Get user_id from request extensions (injected by auth_middleware)
    let user_id = request.extensions().get::<Uuid>().ok_or_else(|| {
        tracing::error!("admin_middleware called without auth_middleware");
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    // Get database pool from request extensions
    let pool = request.extensions().get::<PgPool>().ok_or_else(|| {
        tracing::error!("Database pool not found in request extensions");
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    // Check if user is admin
    let is_admin = check_user_is_admin(pool, *user_id).await.map_err(|e| {
        tracing::error!(user_id = %user_id, error = %e, "Failed to check admin status");
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    if !is_admin {
        tracing::warn!(user_id = %user_id, "User is not admin, access denied");
        return Err(StatusCode::FORBIDDEN);
    }

    tracing::debug!(user_id = %user_id, "Admin user authenticated");

    Ok(next.run(request).await)
}

/// Check if user has admin role in database
async fn check_user_is_admin(pool: &PgPool, user_id: Uuid) -> Result<bool, sqlx::Error> {
    let role: Option<String> = sqlx::query_scalar("SELECT role FROM profiles WHERE id = $1")
        .bind(user_id)
        .fetch_optional(pool)
        .await?;

    match role.as_deref() {
        Some("admin") | Some("subadmin") => Ok(true),
        _ => Ok(false),
    }
}

/// Check if user has moderator role or higher in database
async fn check_user_is_moderator(pool: &PgPool, user_id: Uuid) -> Result<bool, sqlx::Error> {
    let role: Option<String> = sqlx::query_scalar("SELECT role FROM profiles WHERE id = $1")
        .bind(user_id)
        .fetch_optional(pool)
        .await?;

    match role.as_deref() {
        Some("admin") | Some("subadmin") | Some("moderator") => Ok(true),
        _ => Ok(false),
    }
}

/// Moderator middleware - requires auth_middleware to run first
pub async fn moderator_middleware(request: Request, next: Next) -> Result<Response, StatusCode> {
    // Get user_id from request extensions (injected by auth_middleware)
    let user_id = request.extensions().get::<Uuid>().ok_or_else(|| {
        tracing::error!("moderator_middleware called without auth_middleware");
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    // Get database pool from request extensions
    let pool = request.extensions().get::<PgPool>().ok_or_else(|| {
        tracing::error!("Database pool not found in request extensions");
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    // Check if user is moderator or higher
    let is_moderator = check_user_is_moderator(pool, *user_id).await.map_err(|e| {
        tracing::error!(user_id = %user_id, error = %e, "Failed to check moderator status");
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    if !is_moderator {
        tracing::warn!(user_id = %user_id, "User is not moderator, access denied");
        return Err(StatusCode::FORBIDDEN);
    }

    tracing::debug!(user_id = %user_id, "Moderator user authenticated");

    Ok(next.run(request).await)
}
