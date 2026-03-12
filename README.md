# BagInCoffee

> 커피 커뮤니티 서비스를 만들면서, 클라이언트 전환과 도메인 분리를 실제로 검증한 멀티플랫폼 프로젝트

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![SvelteKit](https://img.shields.io/badge/SvelteKit-2.0+-FF3E00?logo=svelte&logoColor=white)](https://kit.svelte.dev)
[![Rust](https://img.shields.io/badge/Rust-1.75+-000000?logo=rust&logoColor=white)](https://www.rust-lang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7+-DC382D?logo=redis&logoColor=white)](https://redis.io)
[![Supabase](https://img.shields.io/badge/Supabase-Auth-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)

BagInCoffee는 커피 애호가를 위한 커뮤니티 서비스입니다.  
피드, 가이드, 장비 탐색, 브루잉 기록을 하나의 경험으로 묶는 것을 목표로 시작했고, 실제 개발 과정에서 `SvelteKit -> Flutter` 전환과 `장비 도메인의 별도 서비스 분리`까지 경험한 프로젝트입니다.

## Portfolio Summary

- 목표: 커피 커뮤니티 서비스를 웹과 모바일에서 일관되게 제공
- 역할: 1인 개발
- 담당: 기획, UI 설계, 프론트엔드, 백엔드, 데이터 모델링, 아키텍처 분리
- 현재 상태: 제품 실험 + 구조 검증 프로젝트

이 저장소는 단순한 앱 구현보다, `서비스를 만들면서 구조를 어떻게 바꿨는가`를 보여주는 데 더 가깝습니다.

## Why This Project Exists

처음에는 SvelteKit 기반 웹 서비스로 빠르게 제품 구조를 검증했습니다.  
하지만 실제로 서비스를 앱까지 확장하려고 보니, 웹앱 방식은 안정성과 사용자 경험 측면에서 한계가 있었습니다.

동시에 커뮤니티 데이터와 장비 데이터는 성격이 완전히 달랐습니다.

- 사용자, 인증, 피드, 콘텐츠
- 브랜드, 카테고리, 제품 스펙, 필터 검색

그래서 클라이언트는 `Flutter`로 전환하고, 장비 영역은 `BagInDB`라는 별도 서비스로 분리했습니다.

## What I Built

### 1. Coffee Community MVP

- 소셜 피드
- 중첩 댓글 구조
- 가이드 / 매거진 콘텐츠
- 브루잉 기록 흐름
- 브랜드 / 장비 탐색

### 2. Cross-platform Client Migration

- 초기 웹 프로토타입: `SvelteKit`
- 전환 후 클라이언트: `Flutter Web + Mobile`
- 목표: 하나의 코드베이스로 웹과 모바일 경험 통합

### 3. Domain Split

- 인증 / 커뮤니티: `Supabase`
- 장비 / 브랜드 / 제품 데이터: `BagInDB`
- 정적 자산: `Cloudflare R2`

즉 BagInCoffee는 `단일 앱`이 아니라, `클라이언트 전환`과 `도메인 분리`를 함께 경험한 프로젝트입니다.

## Key Technical Decisions

- `SvelteKit -> Flutter`
  - 웹 기반 검증에는 SvelteKit이 빠르다고 판단했지만, 장기적으로 웹과 모바일을 함께 가져가려면 Flutter가 더 적합하다고 봤습니다.
- `BagInDB 분리`
  - 커뮤니티 데이터와 장비 데이터는 성격이 달라, 하나의 백엔드에 모두 담기보다 별도 서비스로 나누는 편이 유지보수에 유리했습니다.
- `Rust + Redis`
  - 반복 조회가 많은 장비 API는 리소스 사용을 줄이고 응답을 안정화하기 위해 Rust와 Redis를 선택했습니다.
- `JSONB 기반 장비 스펙`
  - 장비 카테고리마다 필요한 스펙이 달라 고정 스키마보다 JSONB가 더 유연하다고 판단했습니다.
- `Supabase Auth 통합`
  - 웹/모바일/장비 API가 따로 인증을 가지지 않도록 Supabase Auth를 공통 축으로 사용했습니다.

## Results and Current State

현재 기준으로 확인 가능한 결과는 이렇습니다.

- 총 코드량: `51,100+`
- 브랜드 수: `67`
- 카테고리 수: `34`
- 제품 수: `62`
- 지원 언어: `3`
- 캐시 히트율: `85%+`

즉 이 프로젝트는 단순 CRUD 서비스가 아니라,

- 제품 형태를 검증했고
- 클라이언트 기술을 전환했고
- 데이터 도메인을 분리했고
- 캐시까지 도입해 구조를 확장한 프로젝트입니다.

## Screenshots

### Mobile

<p align="center">
  <img src="./screenshots/mobile-login.png" alt="BagInCoffee 모바일 로그인" width="32%">
  <img src="./screenshots/mobile-main.png" alt="BagInCoffee 모바일 메인 화면" width="32%">
</p>

### Web

<p align="center">
  <img src="./screenshots/web-feed.jpg" alt="BagInCoffee 웹 피드" width="45%">
  <img src="./screenshots/web-guide.png" alt="BagInCoffee 웹 가이드" width="45%">
</p>

<p align="center">
  <img src="./screenshots/web-brands.png" alt="BagInCoffee 웹 브랜드 탐색" width="45%">
  <img src="./screenshots/web-marketplace.png" alt="BagInCoffee 웹 마켓플레이스" width="45%">
</p>

## Repository Layout

```text
BagInCoffee/
├── BagInCoffee-App/   # Flutter Web + Mobile
├── BagInCoffee-Web/   # 초기 SvelteKit 프로토타입
├── BagInDB/           # 장비 도메인 백엔드
├── screenshots/
└── README.md
```

## Sub Projects

| Project | Role | Stack |
|---|---|---|
| `BagInCoffee-App` | 메인 클라이언트 | Flutter, Riverpod, Dio |
| `BagInCoffee-Web` | 초기 프로토타입 | SvelteKit, TypeScript, Tailwind CSS |
| `BagInDB` | 장비 도메인 API | Rust, Axum, SQLx, Redis |

## What This Project Shows

- 제품을 만들면서 기술 스택을 재판단한 경험
- 웹에서 모바일까지 확장 가능한 구조를 고민한 과정
- 커뮤니티와 장비 데이터를 분리하는 도메인 설계 능력
- Flutter, Rust, Supabase, Redis를 실제 서비스 흐름에 묶어본 경험

## Related Docs

- [모바일 앱 README](./BagInCoffee-App/README.md)
- [초기 SvelteKit 프로토타입 README](./BagInCoffee-Web/README.md)
- [BagInDB README](./BagInDB/README.md)
- [Supabase 인증 이슈 정리](./BagInCoffee-Web/SUPABASE_AUTH_FIX.md)
- [Svelte 5 마이그레이션 리뷰](./BagInCoffee-Web/SVELTE5_REVIEW.md)
