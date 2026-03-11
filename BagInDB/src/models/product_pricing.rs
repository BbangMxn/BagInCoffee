use chrono::{DateTime, NaiveDate, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct ProductPricing {
    pub id: Uuid,
    pub product_id: Uuid,

    // Price information
    pub currency: String,
    pub price: Option<rust_decimal::Decimal>,

    // Market information
    pub market: Option<String>,
    pub marketplace: Option<String>, // E.g., amazon, aliexpress, coupang, official-store
    pub price_type: Option<String>,

    // Validity period
    pub valid_from: NaiveDate,
    pub valid_until: Option<NaiveDate>,

    // Source and metadata
    pub source: Option<String>,
    pub notes: Option<String>,
    pub is_current: bool,

    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateProductPricingRequest {
    pub product_id: Uuid,
    pub currency: Option<String>,
    pub price: Option<rust_decimal::Decimal>,
    pub market: Option<String>,
    pub marketplace: Option<String>,
    pub price_type: Option<String>,
    pub valid_from: Option<NaiveDate>,
    pub valid_until: Option<NaiveDate>,
    pub source: Option<String>,
    pub notes: Option<String>,
    pub is_current: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateProductPricingRequest {
    pub currency: Option<String>,
    pub price: Option<rust_decimal::Decimal>,
    pub market: Option<String>,
    pub marketplace: Option<String>,
    pub price_type: Option<String>,
    pub valid_from: Option<NaiveDate>,
    pub valid_until: Option<NaiveDate>,
    pub source: Option<String>,
    pub notes: Option<String>,
    pub is_current: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct ProductPricingQuery {
    pub product_id: Option<Uuid>,
    pub marketplace: Option<String>,
    pub market: Option<String>,
    pub currency: Option<String>,
    pub is_current: Option<bool>,
    pub page: Option<i64>,
    pub limit: Option<i64>,
}
