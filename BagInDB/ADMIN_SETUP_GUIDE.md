# Admin 권한 시스템 설정 가이드

## 개요

이 가이드는 BagInDB_v2 프로젝트에 구현된 역할 기반 권한 시스템(Role-Based Access Control)을 설정하고 사용하는 방법을 설명합니다.

CoffeeHena 프로젝트의 profiles 테이블 구조를 기반으로, admin 권한을 가진 사용자만 데이터를 생성/수정/삭제할 수 있도록 구현되었습니다.

## 역할(Roles) 정의

시스템은 4가지 역할을 지원합니다:

| 역할 | 권한 | 설명 |
|------|------|------|
| `user` | 읽기 전용 | 기본 사용자 (모든 데이터 조회 가능) |
| `moderator` | 제품 관리 | 제품 및 가격 정보 생성/수정 가능 |
| `subadmin` | 모든 데이터 관리 | admin과 동일한 권한 |
| `admin` | 전체 관리 | 모든 데이터 생성/수정/삭제 가능 |

## 권한 매트릭스

### Admin/Subadmin 권한
- ✅ 브랜드 생성/수정/삭제
- ✅ 카테고리 생성/수정/삭제
- ✅ 제품 생성/수정/삭제
- ✅ 가격 정보 생성/수정/삭제
- ✅ 캐시 관리

### Moderator 권한
- ❌ 브랜드 관리 (불가)
- ❌ 카테고리 관리 (불가)
- ✅ 제품 생성/수정 (삭제 불가)
- ✅ 가격 정보 생성/수정 (삭제 불가)
- ❌ 캐시 관리 (불가)

### User 권한
- ✅ 모든 데이터 조회만 가능
- ❌ 생성/수정/삭제 불가

## 설치 및 마이그레이션

### 1. 데이터베이스 마이그레이션 적용

마이그레이션 파일이 이미 생성되어 있습니다:

```bash
# Supabase CLI를 사용하여 마이그레이션 적용
supabase db push

# 또는 특정 마이그레이션만 적용
supabase migration up --file 20250111000001_add_profiles_and_admin_policies.sql
```

마이그레이션 파일 위치:
- `supabase/migrations/20250111000001_add_profiles_and_admin_policies.sql`

이 마이그레이션은 다음을 수행합니다:
1. `profiles` 테이블 생성 (role 컬럼 포함)
2. Admin 확인 헬퍼 함수 생성 (`is_admin()`, `is_moderator()`)
3. 기존 RLS 정책을 admin/moderator 전용으로 업데이트
4. 신규 사용자 자동 프로필 생성 트리거 추가

### 2. 첫 번째 Admin 사용자 생성

마이그레이션 후, 최소 한 명의 admin 사용자를 수동으로 설정해야 합니다:

#### Option A: Supabase Dashboard 사용

1. Supabase Dashboard → SQL Editor 열기
2. 다음 쿼리 실행:

```sql
-- 1. 먼저 사용자 ID 확인
SELECT id, email FROM auth.users;

-- 2. 해당 사용자를 admin으로 설정
UPDATE profiles 
SET role = 'admin' 
WHERE id = 'YOUR_USER_ID_HERE';

-- 3. 확인
SELECT id, username, role FROM profiles WHERE role = 'admin';
```

#### Option B: psql 사용

```bash
# Supabase 프로젝트 연결
psql $DATABASE_URL

# admin 권한 부여
UPDATE profiles SET role = 'admin' WHERE id = 'YOUR_USER_ID';
```

#### Option C: Supabase Management API 사용

```bash
# 현재 로그인한 사용자의 ID를 admin으로 설정
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/rest/v1/rpc/make_admin' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_USER_JWT" \
  -H "Content-Type: application/json"
```

## API 사용 예시

### 읽기 (모든 사용자 가능)

```bash
# 브랜드 목록 조회 - 인증 불필요
curl https://your-api.com/api/brands

# 제품 조회 - 인증 불필요
curl https://your-api.com/api/products
```

### 쓰기 (Admin/Moderator 전용)

#### Moderator - 제품 생성

```bash
curl -X POST https://your-api.com/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": {"en": "New Product", "ko": "신제품"},
    "category_id": "...",
    "brand_id": "..."
  }'
```

#### Admin - 브랜드 생성

```bash
curl -X POST https://your-api.com/api/brands \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": {"en": "New Brand", "ko": "새 브랜드"},
    "slug": "new-brand"
  }'
```

#### Admin - 제품 삭제

```bash
curl -X DELETE https://your-api.com/api/products/PRODUCT_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 에러 응답

### 401 Unauthorized
- JWT 토큰이 없거나 유효하지 않음
- 로그인이 필요함

```json
{
  "error": "Unauthorized"
}
```

### 403 Forbidden
- 로그인은 했지만 권한이 부족함
- admin/moderator 권한이 필요한 작업

```json
{
  "error": "Forbidden"
}
```

## Rust 코드에서 사용 방법

### Middleware 구조

```rust
use crate::middleware::{
    auth_middleware,      // JWT 인증
    admin_middleware,     // Admin 전용
    moderator_middleware  // Moderator 이상
};

// Admin 전용 라우트
Router::new()
    .route("/api/brands", post(create_brand))
    .layer(from_fn(inject_pool))
    .layer(from_fn(auth_middleware))
    .layer(from_fn(admin_middleware));

// Moderator 이상 가능 라우트
Router::new()
    .route("/api/products", post(create_product))
    .layer(from_fn(inject_pool))
    .layer(from_fn(auth_middleware))
    .layer(from_fn(moderator_middleware));
```

### 현재 라우트 구조

파일: `src/routes/mod.rs`

- **Public routes**: 인증 없이 조회 가능
- **Moderator routes**: 제품/가격 생성/수정
- **Admin routes**: 브랜드/카테고리 관리, 모든 삭제 작업

## 보안 고려사항

### Row Level Security (RLS)

데이터베이스 레벨에서도 이중 검증이 적용됩니다:

1. **Application Level**: Rust middleware에서 role 확인
2. **Database Level**: Supabase RLS 정책에서 `is_admin()`, `is_moderator()` 함수로 재확인

이중 검증으로 API를 우회한 직접 DB 접근도 차단됩니다.

### 자동 프로필 생성

새 사용자가 가입하면 자동으로 `user` 역할의 프로필이 생성됩니다:

```sql
-- auth.users에 INSERT 트리거
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE handle_new_user();
```

기본 역할은 항상 `user`이며, admin만 다른 사용자의 역할을 변경할 수 있습니다.

## 테스트 방법

### 1. 사용자 등록 및 프로필 확인

```sql
-- 새 프로필 확인
SELECT id, username, role, created_at FROM profiles ORDER BY created_at DESC LIMIT 5;
```

### 2. 권한 테스트

```bash
# User로 제품 생성 시도 (실패해야 함)
curl -X POST https://your-api.com/api/products \
  -H "Authorization: Bearer USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{"name": {"en": "Test", "ko": "테스트"}}'
# 예상 결과: 403 Forbidden

# Admin으로 브랜드 생성 (성공해야 함)
curl -X POST https://your-api.com/api/brands \
  -H "Authorization: Bearer ADMIN_JWT" \
  -H "Content-Type: application/json" \
  -d '{"name": {"en": "Test Brand", "ko": "테스트 브랜드"}, "slug": "test-brand"}'
# 예상 결과: 200 OK
```

## 문제 해결

### "User is not admin, access denied" 에러

1. 프로필 확인:
```sql
SELECT id, role FROM profiles WHERE id = auth.uid();
```

2. 역할이 `user`인 경우, admin이 다음 쿼리로 업그레이드:
```sql
UPDATE profiles SET role = 'admin' WHERE id = 'USER_ID';
```

### "Database pool not found" 에러

- Middleware 순서 확인: `inject_pool` → `auth_middleware` → `admin_middleware`
- 라우터에 pool이 제대로 주입되었는지 확인

### RLS 정책 오류

```sql
-- 현재 활성화된 정책 확인
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('brands', 'products', 'product_categories', 'profiles')
ORDER BY tablename, policyname;
```

## 추가 개선 사항

### 역할 변경 API 추가 (선택사항)

Admin이 다른 사용자의 역할을 변경할 수 있는 엔드포인트:

```rust
// src/handlers/admin.rs (새 파일)
pub async fn update_user_role(
    Extension(pool): Extension<PgPool>,
    Extension(current_user_id): Extension<Uuid>,
    Path(user_id): Path<Uuid>,
    Json(payload): Json<UpdateRolePayload>,
) -> Result<StatusCode, StatusCode> {
    // 현재 사용자가 admin인지 확인
    // user_id의 역할을 payload.role로 변경
    // ...
}
```

### 감사 로그 (Audit Log)

Admin 작업을 추적하기 위한 로그 테이블:

```sql
CREATE TABLE admin_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL,  -- 'create', 'update', 'delete'
    table_name TEXT NOT NULL,
    record_id UUID,
    changes JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 요약

✅ **완료된 작업:**
1. `profiles` 테이블 생성 (역할 기반 권한)
2. Admin/Moderator 확인 함수 구현
3. RLS 정책 업데이트 (Admin/Moderator 전용)
4. Rust middleware 구현 (`admin_middleware`, `moderator_middleware`)
5. 라우트 분리 (Public / Moderator / Admin)

🔧 **다음 단계:**
1. 마이그레이션 적용: `supabase db push`
2. 첫 admin 사용자 설정
3. API 테스트
4. 프론트엔드에 역할 기반 UI 구현 (선택사항)
