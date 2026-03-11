use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct ProductCategory {
    pub id: Uuid,
    pub slug: String,

    // Hierarchy
    pub parent_id: Option<Uuid>,
    pub level: i32,
    pub path: Option<String>,

    // Multi-language
    pub name: serde_json::Value,
    pub description: Option<serde_json::Value>,

    // Spec table mapping (deprecated - using products.specs JSONB now)
    pub spec_table_name: Option<String>,

    // Spec schema for dynamic filtering
    pub spec_schema: Option<serde_json::Value>,

    // Icons/Images
    pub icon_url: Option<String>,
    pub image_url: Option<String>,

    // Meta
    pub product_count: i32,
    pub display_order: i32,
    pub is_active: bool,
    pub is_accessory: bool, // True if this category represents accessories for a parent equipment type

    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateProductCategoryRequest {
    pub slug: String,
    pub parent_id: Option<Uuid>,
    pub level: Option<i32>,
    pub path: Option<String>,
    pub name: serde_json::Value,
    pub description: Option<serde_json::Value>,
    pub spec_table_name: Option<String>,
    pub icon_url: Option<String>,
    pub image_url: Option<String>,
    pub display_order: Option<i32>,
    pub is_active: Option<bool>,
    pub is_accessory: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateProductCategoryRequest {
    pub slug: Option<String>,
    pub parent_id: Option<Uuid>,
    pub path: Option<String>,
    pub name: Option<serde_json::Value>,
    pub description: Option<serde_json::Value>,
    pub spec_table_name: Option<String>,
    pub icon_url: Option<String>,
    pub image_url: Option<String>,
    pub display_order: Option<i32>,
    pub is_active: Option<bool>,
    pub is_accessory: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct ProductCategoryQuery {
    pub locale: Option<String>,
    pub parent_id: Option<Uuid>,
    pub level: Option<i32>,
    pub is_active: Option<bool>,
    pub search: Option<String>,
    pub page: Option<i64>,
    pub limit: Option<i64>,
}
