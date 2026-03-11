# BagInDB Deployment Guide

## Railway 배포 가이드

### 1. Railway 프로젝트 설정

1. [Railway](https://railway.app) 계정 생성/로그인
2. **New Project** 클릭
3. **Deploy from GitHub repo** 선택
4. `BbangMxnUser/BagInDB` 저장소 선택

### 2. 환경 변수 설정

Railway 대시보드의 **Variables** 탭에서 다음 환경 변수를 추가:

```env
DATABASE_URL=postgresql://postgres.naizypxglszbxemqnouv:xweuev4ImPPDYnmvCFlgo6rCfRgBDtMHU83WaeESQgGyeRUDzp@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres

SUPABASE_JWT_SECRET=I9gSFpFVW9oaTpG4KyHsymbKft3ZmVr//GPRYOozBuK5DMmGFR9GNEgEKaKFvKKnpiSq6NJUvlFRJ2/p6U7KOg==

SERVER_HOST=0.0.0.0
SERVER_PORT=8080

RUST_LOG=info
```

### 3. 배포

- Railway가 자동으로 Dockerfile을 감지하고 빌드합니다
- 빌드 완료 후 자동으로 배포됩니다
- 배포 URL: `https://your-app.railway.app`

### 4. 배포 확인

```bash
# Health check
curl https://your-app.railway.app/health

# 브랜드 목록 조회
curl https://your-app.railway.app/api/brands
```

## 로컬 Docker 테스트

### Docker 이미지 빌드

```bash
docker build -t bag-in-db .
```

### Docker 컨테이너 실행

```bash
docker run -p 8080:8080 \
  -e DATABASE_URL="your_database_url" \
  -e SUPABASE_JWT_SECRET="your_jwt_secret" \
  bag-in-db
```

### Docker Compose 사용 (선택사항)

`docker-compose.yml` 파일 생성:

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - SUPABASE_JWT_SECRET=${SUPABASE_JWT_SECRET}
      - RUST_LOG=info
      - SERVER_HOST=0.0.0.0
      - SERVER_PORT=8080
    restart: unless-stopped
```

실행:

```bash
docker-compose up -d
```

## API 인증

### JWT 토큰 획득 (Supabase Auth)

```javascript
// Supabase 클라이언트에서 로그인
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password'
})

// JWT 토큰
const token = data.session.access_token
```

### 인증이 필요한 요청 예시

```bash
# 브랜드 생성 (인증 필요)
curl -X POST https://your-app.railway.app/api/brands \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "test-brand",
    "name": {"ko": "테스트 브랜드", "en": "Test Brand"},
    "country": "KR",
    "is_active": true,
    "featured": false,
    "verified": false
  }'
```

## 트러블슈팅

### 빌드 실패 시

1. Rust 버전 확인: Dockerfile의 `rust:1.75-slim` 버전이 최신인지 확인
2. 의존성 문제: `Cargo.lock` 파일이 커밋되었는지 확인

### 데이터베이스 연결 실패 시

1. DATABASE_URL이 정확한지 확인
2. Supabase IP 허용 목록에 Railway IP 추가 (또는 `0.0.0.0/0` 사용)
3. Connection Pooler URL 사용 확인

### 메모리 부족 시

Railway 플랜 업그레이드 또는 Dockerfile 최적화 고려

## 모니터링

Railway 대시보드에서 다음을 확인할 수 있습니다:

- **Deployments**: 배포 내역 및 로그
- **Metrics**: CPU, 메모리, 네트워크 사용량
- **Logs**: 실시간 애플리케이션 로그

## 환경별 설정

### 개발 환경

```env
RUST_LOG=debug
```

### 프로덕션 환경

```env
RUST_LOG=info
```

## 보안 고려사항

1. ✅ 환경 변수로 민감 정보 관리 (.env 파일 gitignore)
2. ✅ JWT 인증으로 쓰기 작업 보호
3. ✅ HTTPS 사용 (Railway 자동 제공)
4. ✅ Non-root 사용자로 컨테이너 실행
5. ⚠️ CORS 설정 필요 시 main.rs에서 조정
