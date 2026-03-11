<!-- PROJECT SHIELDS -->
<div align="center">

[![Rust][rust-shield]][rust-url]
[![Axum][axum-shield]][axum-url]
[![PostgreSQL][postgres-shield]][postgres-url]
[![License][license-shield]][license-url]

</div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/BbangMxn/BagInDB">
    <img src="docs/logo.png" alt="Logo" width="100" height="100">
  </a>

  <h3 align="center">BagInDB</h3>

  <p align="center">
    커피 장비 데이터베이스 API
    <br />
    <a href="#-api"><strong>API 문서 »</strong></a>
    <br />
    <br />
    <a href="#-빠른-시작">빠른 시작</a>
    ·
    <a href="https://github.com/BbangMxn/BagInDB/issues">버그 리포트</a>
    ·
    <a href="https://github.com/BbangMxn/BagInDB/issues">기능 제안</a>
  </p>
</div>

<!-- ABOUT -->
## 프로젝트 소개

**BagInDB**는 Rust 기반 고성능 커피 장비 데이터베이스 API입니다.

- 🌍 **다국어** — JSONB 기반 i18n (한/영/일)
- ⚡ **Redis 캐싱** — 지능형 캐시, 자동 무효화
- 🔍 **검색** — 전문 검색, 다중 필터
- 📦 **장비 관리** — 브랜드, 카테고리, 제품 스펙

### 기술 스택

[![Rust][rust-badge]][rust-url]
[![Axum][axum-badge]][axum-url]
[![PostgreSQL][postgres-badge]][postgres-url]
[![Redis][redis-badge]][redis-url]

---

## 📈 주요 성과

| 지표 | 결과 |
|-----|------|
| **응답 속도** | < 10ms (캐시 히트) |
| **캐시 적중률** | 85%+ |
| **다국어 지원** | 3개 언어 (ko/en/ja) |
| **API 엔드포인트** | 15+ 개 |

---

## 🔧 기술적 도전과 해결

### 1. 다국어 데이터 저장

**문제:** 언어별 컬럼 추가 시 스키마 복잡성 증가

**해결:**
```sql
-- JSONB로 다국어 데이터 저장
CREATE TABLE brands (
    id UUID PRIMARY KEY,
    name JSONB NOT NULL,  -- {"ko": "라마르조코", "en": "La Marzocco"}
    description JSONB
);

-- 쿼리 시 언어 선택
SELECT name->>'ko' as name_ko FROM brands;
```

### 2. 캐시 일관성 문제

**문제:** 데이터 변경 시 캐시 불일치

**해결:**
```rust
// 자동 캐시 무효화 전략
async fn update_brand(id: Uuid, data: BrandUpdate) -> Result<Brand> {
    let brand = db.update(id, data).await?;
    
    // 관련 캐시 모두 삭제
    cache.delete(&format!("brand:{}", id)).await?;
    cache.delete("brands:all").await?;
    
    Ok(brand)
}
```

### 3. 복잡한 필터 쿼리 성능

**문제:** 다중 조건 필터 시 쿼리 지연

**해결:**
- 복합 인덱스 생성
- 쿼리 결과 캐싱 (5분 TTL)
- 페이지네이션 적용

---

## 🚀 빠른 시작

```bash
# 1. 클론
git clone https://github.com/BbangMxn/BagInDB.git
cd BagInDB

# 2. 환경변수
cp .env.example .env

# 3. 실행
cargo run
```

---

## 📡 API

| Method | Endpoint | 설명 |
|--------|----------|------|
| `GET` | `/api/brands` | 브랜드 목록 |
| `GET` | `/api/brands/:id` | 브랜드 상세 |
| `GET` | `/api/products` | 제품 목록 |
| `GET` | `/api/products/:id` | 제품 상세 |
| `GET` | `/api/categories` | 카테고리 목록 |

### 다국어 쿼리

```http
GET /api/brands?locale=ko
GET /api/products?locale=en&country=US
```

---

## ⚡ 캐싱 전략

| 키 패턴 | TTL | 설명 |
|--------|:---:|------|
| `brands:all` | 10분 | 브랜드 목록 |
| `brand:{id}` | 15분 | 브랜드 상세 |
| `products:page:{n}` | 5분 | 제품 목록 |
| `product:{id}` | 15분 | 제품 상세 |

---

## 📂 프로젝트 구조

```
src/
├── main.rs
├── config.rs        # 환경설정
├── routes/          # API 라우트
│   ├── brands.rs
│   ├── products.rs
│   └── categories.rs
├── models/          # 데이터 모델
├── repository/      # 데이터 접근
└── cache/           # Redis 캐시
```

---

## 🗺️ 로드맵

- [x] 브랜드/제품 API
- [x] 다국어 지원
- [x] Redis 캐싱
- [ ] 검색 API
- [ ] 가격 추적

---

## 📄 라이선스

MIT License - [LICENSE](LICENSE)

---

<div align="center">
  
**[⬆ 맨 위로](#bagindb)**

</div>

<!-- MARKDOWN LINKS -->
[rust-shield]: https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white
[rust-url]: https://www.rust-lang.org/
[axum-shield]: https://img.shields.io/badge/Axum-000000?style=for-the-badge
[axum-url]: https://github.com/tokio-rs/axum
[postgres-shield]: https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white
[postgres-url]: https://www.postgresql.org/
[license-shield]: https://img.shields.io/badge/License-MIT-blue?style=for-the-badge
[license-url]: LICENSE

[rust-badge]: https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white
[axum-badge]: https://img.shields.io/badge/Axum-000000?style=for-the-badge
[postgres-badge]: https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white
[redis-badge]: https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white
[redis-url]: https://redis.io/
