use chrono::{DateTime, NaiveDate, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Product {
    pub id: Uuid,
    pub slug: String,

    // Relations
    pub category_id: Uuid,
    pub brand_id: Uuid,

    // Basic info
    pub name: serde_json::Value,
    pub description: Option<serde_json::Value>,

    // Identifiers
    pub model_number: Option<String>,
    pub identifiers: Option<serde_json::Value>,

    // Images
    pub image_url: Option<String>,
    pub images: Option<Vec<String>>,

    // Manufacturing info
    pub manufacturer_country: Option<String>,
    pub release_date: Option<NaiveDate>,
    pub discontinued_date: Option<NaiveDate>,

    // Wiki meta
    pub view_count: i32,
    pub edit_count: i32,
    pub is_verified: bool,

    // Multi-language settings
    pub available_locales: Vec<String>,
    pub default_locale: String,

    // Physical specifications (common fields)
    pub dimensions: Option<serde_json::Value>,
    pub weight: Option<serde_json::Value>,
    pub power_watts: Option<i32>,
    pub voltage: Option<String>,

    // Unified product specifications as JSONB
    pub specs: Option<serde_json::Value>,

    // Pricing information
    pub current_price_min: Option<i32>,
    pub current_price_max: Option<i32>,
    pub current_price_currency: Option<String>,
    pub current_price_updated_at: Option<DateTime<Utc>>,

    // Purchase links
    pub purchase_links: Option<serde_json::Value>,
    pub official_url: Option<String>,

    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateProductRequest {
    pub slug: String,
    pub category_id: Uuid,
    pub brand_id: Uuid,
    pub name: serde_json::Value,
    pub description: Option<serde_json::Value>,
    pub model_number: Option<String>,
    pub identifiers: Option<serde_json::Value>,
    pub image_url: Option<String>,
    pub images: Option<Vec<String>>,
    pub manufacturer_country: Option<String>,
    pub release_date: Option<NaiveDate>,
    pub discontinued_date: Option<NaiveDate>,
    pub is_verified: Option<bool>,
    pub available_locales: Option<Vec<String>>,
    pub default_locale: Option<String>,

    // Physical specs and pricing
    pub dimensions: Option<serde_json::Value>,
    pub weight: Option<serde_json::Value>,
    pub power_watts: Option<i32>,
    pub voltage: Option<String>,
    pub specs: Option<serde_json::Value>,
    pub current_price_min: Option<i32>,
    pub current_price_max: Option<i32>,
    pub current_price_currency: Option<String>,
    pub purchase_links: Option<serde_json::Value>,
    pub official_url: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateProductRequest {
    pub slug: Option<String>,
    pub category_id: Option<Uuid>,
    pub brand_id: Option<Uuid>,
    pub name: Option<serde_json::Value>,
    pub description: Option<serde_json::Value>,
    pub model_number: Option<String>,
    pub identifiers: Option<serde_json::Value>,
    pub image_url: Option<String>,
    pub images: Option<Vec<String>>,
    pub manufacturer_country: Option<String>,
    pub release_date: Option<NaiveDate>,
    pub discontinued_date: Option<NaiveDate>,
    pub is_verified: Option<bool>,
    pub available_locales: Option<Vec<String>>,
    pub default_locale: Option<String>,

    // Physical specs and pricing
    pub dimensions: Option<serde_json::Value>,
    pub weight: Option<serde_json::Value>,
    pub power_watts: Option<i32>,
    pub voltage: Option<String>,
    pub specs: Option<serde_json::Value>,
    pub current_price_min: Option<i32>,
    pub current_price_max: Option<i32>,
    pub current_price_currency: Option<String>,
    pub purchase_links: Option<serde_json::Value>,
    pub official_url: Option<String>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct ProductQuery {
    pub locale: Option<String>,
    #[serde(default, deserialize_with = "deserialize_optional_uuid")]
    pub category_id: Option<Uuid>,
    #[serde(default, deserialize_with = "deserialize_optional_uuid")]
    pub brand_id: Option<Uuid>,
    pub is_verified: Option<bool>,
    pub search: Option<String>,
    pub page: Option<i64>,
    pub limit: Option<i64>,

    // Price filters
    pub price_min: Option<i32>,
    pub price_max: Option<i32>,
    pub currency: Option<String>,

    // Sort options
    pub sort_by: Option<String>, // created_at, price, name, etc.
    pub order: Option<String>,   // asc, desc

    // Dynamic JSONB spec filters
    // Format: spec_{field_name} for equality
    //         spec_{field_name}_min/_max for ranges
    //         spec_{field_name}_contains for array contains
    //
    // Examples in query string:
    // ?spec_machine_type=semi-automatic
    // ?spec_burr_size_mm_min=54&spec_burr_size_mm_max=64
    // ?spec_dual_boiler=true
    // ?spec_heat_sources_contains=induction
    #[serde(flatten)]
    pub spec_filters: std::collections::HashMap<String, String>,
}

/// UUID 파싱 실패 시 None으로 처리하는 커스텀 deserializer
fn deserialize_optional_uuid<'de, D>(deserializer: D) -> Result<Option<Uuid>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let opt: Option<String> = Option::deserialize(deserializer)?;
    match opt {
        Some(s) if !s.is_empty() => match Uuid::parse_str(&s) {
            Ok(uuid) => Ok(Some(uuid)),
            Err(_) => Ok(None), // 파싱 실패 시 None 반환 (오류 대신)
        },
        _ => Ok(None),
    }
}

impl ProductQuery {
    /// 캐시 키용 필터 해시 생성
    pub fn to_cache_hash(&self) -> String {
        use std::collections::hash_map::DefaultHasher;
        use std::hash::{Hash, Hasher};

        let json = serde_json::to_string(self).unwrap_or_default();
        let mut hasher = DefaultHasher::new();
        json.hash(&mut hasher);
        format!("{:x}", hasher.finish())
    }
}
