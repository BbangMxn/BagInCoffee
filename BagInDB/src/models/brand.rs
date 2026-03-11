use chrono::{DateTime, NaiveDate, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

// Brand Entity - matches actual DB schema exactly
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Brand {
    pub id: Uuid,
    pub slug: String,

    // JSONB fields - using serde_json::Value for flexibility
    pub name: serde_json::Value, // JSONB with {en, ko} required
    pub description: Option<serde_json::Value>,
    pub headquarters: Option<serde_json::Value>,

    // Images
    pub logo_url: Option<String>,
    pub images: Option<Vec<String>>,

    // Info
    pub website: Option<String>,
    pub country: Option<String>,
    pub founded_date: Option<NaiveDate>,
    pub founded_year: Option<i32>, // Auto-generated from founded_date
    pub specialization: Option<Vec<String>>,

    // Flags
    pub is_active: bool,
    pub featured: bool,
    pub verified: bool,

    // Multi-language settings
    pub available_locales: Option<Vec<String>>,
    pub default_locale: Option<String>,

    // Timestamps
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateBrandRequest {
    pub slug: String,
    pub name: serde_json::Value, // Must contain {en, ko} keys
    pub description: Option<serde_json::Value>,
    pub headquarters: Option<serde_json::Value>,
    pub logo_url: Option<String>,
    pub images: Option<Vec<String>>,
    pub website: Option<String>,
    pub country: Option<String>,
    pub founded_date: Option<NaiveDate>,
    pub specialization: Option<Vec<String>>,
    pub is_active: Option<bool>,
    pub featured: Option<bool>,
    pub verified: Option<bool>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct UpdateBrandRequest {
    pub slug: Option<String>,
    pub name: Option<serde_json::Value>,
    pub description: Option<serde_json::Value>,
    pub headquarters: Option<serde_json::Value>,
    pub logo_url: Option<String>,
    pub images: Option<Vec<String>>,
    pub website: Option<String>,
    pub country: Option<String>,
    pub founded_date: Option<NaiveDate>,
    pub specialization: Option<Vec<String>>,
    pub is_active: Option<bool>,
    pub featured: Option<bool>,
    pub verified: Option<bool>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct BrandFilter {
    pub slug: Option<String>,
    pub country: Option<String>,
    pub is_active: Option<bool>,
    pub featured: Option<bool>,
    pub verified: Option<bool>,
    pub specialization: Option<String>,
    pub search: Option<String>,
    pub limit: Option<i64>,
    pub page: Option<i64>,
    pub offset: Option<i64>,
}
