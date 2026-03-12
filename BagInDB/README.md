# BagInDB

> 커뮤니티 서비스에서 분리한 커피 장비 도메인을 Rust로 설계한 저리소스 장비 데이터 API

[![Rust](https://img.shields.io/badge/Rust-1.75+-000000?logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Axum](https://img.shields.io/badge/Axum-000000?style=flat-square)](https://github.com/tokio-rs/axum)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7+-DC382D?logo=redis&logoColor=white)](https://redis.io/)

BagInDB는 원래 `BagInCoffee` 안에 있던 장비 도메인을 별도로 분리한 프로젝트입니다.  
브랜드, 카테고리, 제품 스펙처럼 반복 조회가 많고 구조가 자주 변하는 데이터를 `Rust + PostgreSQL + Redis` 조합으로 설계해, 커뮤니티 서비스와 분리된 독립 API로 운영하는 것을 목표로 했습니다.

## Portfolio Summary

- 목표: 커피 장비 데이터를 위한 별도 백엔드 서비스 설계
- 역할: 1인 개발
- 담당: 데이터 모델링, API 설계, 캐싱 전략, 인증 검증, 문서화
- 현재 상태: 장비 도메인 백엔드 프로토타입

## Why This Project Exists

커뮤니티 서비스와 장비 데이터 서비스는 요구사항이 다릅니다.

- 커뮤니티: 사용자, 인증, 피드, 콘텐츠
- 장비 데이터: 브랜드, 카테고리, 제품 스펙, 필터 검색, 다국어 표현

이 둘을 같은 서비스에 계속 쌓는 것보다, 장비 데이터만 따로 다루는 서비스로 분리하는 편이 더 적합하다고 판단했습니다.  
그래서 BagInDB는 `BagInCoffee`의 하위 모듈이 아니라, 별도 도메인 서비스로 설계됐습니다.

## What I Built

- 브랜드 API
- 카테고리 API
- 제품 목록 / 상세 API
- JSONB 기반 다국어 필드
- Redis 캐시 계층
- JWT 검증 흐름
- 필터 기반 조회 구조

핵심은 `장비 데이터`를 제품 서비스 수준으로 다루는 것이었습니다.

## Key Technical Decisions

- `Rust`
  - 반복 조회가 많고 장기 실행되는 API는 리소스 사용량을 낮게 가져가고 싶어 Rust를 선택했습니다.
- `JSONB 기반 스펙 저장`
  - 카테고리마다 제품 스펙 구조가 달라, 정규화만으로는 유연성이 떨어진다고 판단했습니다.
- `Redis 캐시`
  - 브랜드 / 제품 / 목록 조회처럼 반복 요청이 많은 엔드포인트에 캐시를 붙여 응답 비용을 줄였습니다.
- `도메인 분리`
  - 커뮤니티와 장비 데이터가 한 서버 안에서 결합되지 않도록 독립 서비스로 나눴습니다.

## Results and Current State

현재 기준으로 README에 정리할 수 있는 관측값은 이렇습니다.

- 응답 속도: `< 10ms` cache hit
- 캐시 적중률: `85%+`
- 다국어 지원: `ko / en / ja`
- API 엔드포인트: `15+`

즉 BagInDB는 단순한 CRUD 저장소가 아니라,

- 다국어 장비 데이터 모델을 설계했고
- 캐싱과 무효화 전략을 적용했고
- 독립 서비스로 분리해 운영 가능성을 검토한 프로젝트입니다.

## Example API

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/brands` | 브랜드 목록 |
| `GET` | `/api/brands/:id` | 브랜드 상세 |
| `GET` | `/api/products` | 제품 목록 |
| `GET` | `/api/products/:id` | 제품 상세 |
| `GET` | `/api/categories` | 카테고리 목록 |

다국어 조회 예시:

```http
GET /api/brands?locale=ko
GET /api/products?locale=en&country=US
```

## Project Layout

```text
src/
├── main.rs
├── config.rs
├── routes/
├── models/
├── repository/
└── cache/
```

## What This Project Shows

- 서비스를 도메인 단위로 분리하는 설계 경험
- Rust 기반 저리소스 API 서버 구현 경험
- PostgreSQL JSONB와 Redis를 실제 데이터 API에 적용한 경험
- 다국어 장비 데이터 모델링과 캐시 무효화 전략 설계 경험
