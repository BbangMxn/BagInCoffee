use redis::{aio::ConnectionManager, Client, RedisError};
use serde::{de::DeserializeOwned, Serialize};
use std::time::Duration;

/// Redis 캐시 클라이언트
#[derive(Clone)]
pub struct CacheClient {
    conn: ConnectionManager,
}

impl CacheClient {
    /// Redis 연결 생성
    pub async fn new(redis_url: &str) -> Result<Self, RedisError> {
        let client = Client::open(redis_url)?;
        let conn = ConnectionManager::new(client).await?;

        tracing::info!("Redis connection established");

        Ok(Self { conn })
    }

    /// 캐시에서 값 가져오기
    pub async fn get<T: DeserializeOwned>(&self, key: &str) -> Result<Option<T>, RedisError> {
        let mut conn = self.conn.clone();
        let value: Option<String> = redis::cmd("GET").arg(key).query_async(&mut conn).await?;

        match value {
            Some(json) => {
                let data = serde_json::from_str(&json).map_err(|e| {
                    RedisError::from((
                        redis::ErrorKind::TypeError,
                        "JSON parse error",
                        e.to_string(),
                    ))
                })?;
                Ok(Some(data))
            }
            None => Ok(None),
        }
    }

    /// 캐시에 값 저장 (TTL 설정)
    pub async fn set<T: Serialize>(
        &self,
        key: &str,
        value: &T,
        ttl: Duration,
    ) -> Result<(), RedisError> {
        let mut conn = self.conn.clone();
        let json = serde_json::to_string(value).map_err(|e| {
            RedisError::from((
                redis::ErrorKind::TypeError,
                "JSON serialize error",
                e.to_string(),
            ))
        })?;

        redis::cmd("SETEX")
            .arg(key)
            .arg(ttl.as_secs())
            .arg(json)
            .query_async::<_, ()>(&mut conn)
            .await?;

        Ok(())
    }

    /// 캐시 키 삭제
    pub async fn delete(&self, key: &str) -> Result<(), RedisError> {
        let mut conn = self.conn.clone();
        redis::cmd("DEL")
            .arg(key)
            .query_async::<_, ()>(&mut conn)
            .await?;

        Ok(())
    }

    /// 패턴으로 키 삭제 (예: "products:*")
    pub async fn delete_pattern(&self, pattern: &str) -> Result<(), RedisError> {
        let mut conn = self.conn.clone();

        // SCAN으로 패턴에 맞는 키 찾기
        let keys: Vec<String> = redis::cmd("KEYS")
            .arg(pattern)
            .query_async(&mut conn)
            .await?;

        if !keys.is_empty() {
            redis::cmd("DEL")
                .arg(&keys)
                .query_async::<_, ()>(&mut conn)
                .await?;
        }

        Ok(())
    }

    /// 모든 캐시 삭제 (서버 시작 시 초기화용)
    pub async fn flush_all(&self) -> Result<(), RedisError> {
        let mut conn = self.conn.clone();
        redis::cmd("FLUSHDB")
            .query_async::<_, ()>(&mut conn)
            .await?;
        tracing::info!("Redis cache flushed");
        Ok(())
    }
}

/// 캐시 키 생성 헬퍼
pub mod keys {
    use uuid::Uuid;

    /// 제품 목록 캐시 키 (필터 해시 포함)
    pub fn products_list(filter_hash: &str, page: i64) -> String {
        format!("products:filter:{}:page:{}", filter_hash, page)
    }

    /// 특정 제품 캐시 키
    pub fn product(id: Uuid) -> String {
        format!("product:{}", id)
    }

    /// 카테고리 목록 캐시 키
    pub fn categories() -> String {
        "categories:all".to_string()
    }

    /// 브랜드 목록 캐시 키
    pub fn brands() -> String {
        "brands:all".to_string()
    }

    /// 제품 스펙 캐시 키
    pub fn product_specs(product_id: Uuid) -> String {
        format!("product:{}:specs", product_id)
    }

    /// 제품 가격 정보 캐시 키 (현재 유효한 가격)
    pub fn product_current_pricing(product_id: Uuid) -> String {
        format!("product:{}:pricing:current", product_id)
    }

    /// 특정 가격 정보 캐시 키
    pub fn pricing(id: Uuid) -> String {
        format!("pricing:{}", id)
    }
}
