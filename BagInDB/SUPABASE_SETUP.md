# Supabase 설정 가이드

BagInDB 프로젝트의 Supabase 설정 방법을 안내합니다.

## 1. Supabase 프로젝트 생성

1. [Supabase Dashboard](https://app.supabase.com) 접속
2. "New Project" 클릭
3. 프로젝트 정보 입력:
   - **Name**: `BagInDB-Production` (또는 원하는 이름)
   - **Database Password**: 강력한 비밀번호 생성 (저장 필수!)
   - **Region**: 가장 가까운 리전 선택 (예: Northeast Asia - Seoul)
4. "Create new project" 클릭하고 데이터베이스 준비 대기 (약 2분)

## 2. 데이터베이스 연결 정보 확인

1. 프로젝트 대시보드에서 **Settings** → **Database** 클릭
2. **Connection string** 섹션에서 "URI" 복사
3. `.env` 파일에 저장:
   ```env
   DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
   ```

## 3. 마이그레이션 실행

Supabase Dashboard의 SQL Editor에서 순서대로 실행:

### Step 1: 기본 스키마 생성
```sql
-- supabase/migrations/20250104000001_initial_schema.sql 내용 복사해서 실행
```

이 마이그레이션은:
- ✅ UUID, pg_trgm 확장 활성화
- ✅ brands 테이블 생성
- ✅ product_categories 테이블 생성
- ✅ products 테이블 생성
- ✅ 인덱스 및 트리거 생성

### Step 2: 스펙 테이블 생성
```sql
-- supabase/migrations/20250104000002_spec_tables.sql 내용 복사해서 실행
```

이 마이그레이션은:
- ✅ espresso_machine_specs 테이블
- ✅ drip_coffee_maker_specs 테이블
- ✅ coffee_grinder_specs 테이블
- ✅ moka_pot_specs 테이블
- ✅ coffee_accessory_specs 테이블

### Step 3: RLS 정책 설정
```sql
-- supabase/migrations/20250104000003_rls_policies.sql 내용 복사해서 실행
```

이 마이그레이션은:
- ✅ 모든 테이블에 RLS 활성화
- ✅ Public read 정책 (누구나 조회 가능)
- ✅ Authenticated write 정책 (인증된 사용자만 수정)
- ✅ Service role delete 정책 (관리자만 삭제)

### Step 4: Storage 설정
```sql
-- supabase/migrations/20250104000004_storage_setup.sql 내용 복사해서 실행
```

이 마이그레이션은:
- ✅ brand-images 버킷 생성
- ✅ equipment-images 버킷 생성
- ✅ Storage 정책 설정

### Step 5 (선택사항): 샘플 데이터
```sql
-- supabase/seed.sql 내용 복사해서 실행
```

이 시드 데이터는:
- ✅ 4개 샘플 브랜드 (La Marzocco, Hario, Comandante, Bialetti)
- ✅ 5개 제품 카테고리

## 4. Storage 버킷 확인

1. Supabase Dashboard에서 **Storage** 클릭
2. 다음 버킷이 생성되었는지 확인:
   - `brand-images` (Public, 10MB 제한)
   - `equipment-images` (Public, 10MB 제한)
3. 각 버킷을 클릭하고 **Policies** 탭에서 정책 확인

## 5. API Keys 확인

1. **Settings** → **API** 클릭
2. 다음 키들을 확인 및 저장:
   - **Project URL**: `https://[PROJECT-REF].supabase.co`
   - **anon public key**: 프론트엔드에서 사용
   - **service_role key**: 백엔드/관리자 작업용 (절대 노출 금지!)

## 6. 환경 변수 설정

`.env` 파일 완성:

```env
# Database
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres

# Server
SERVER_HOST=0.0.0.0
SERVER_PORT=8080
RUST_LOG=info

# Supabase (프론트엔드에서 사용)
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_ANON_KEY=[YOUR-ANON-KEY]
SUPABASE_SERVICE_ROLE_KEY=[YOUR-SERVICE-ROLE-KEY]
```

## 7. 테스트

### 데이터베이스 연결 테스트
```bash
cargo run
```

서버가 시작되면 다음 확인:
```bash
# Health check
curl http://localhost:8080/health

# 브랜드 목록 조회
curl http://localhost:8080/api/brands
```

### Supabase 직접 쿼리 테스트

SQL Editor에서:
```sql
-- 브랜드 확인
SELECT slug, name->>'ko' as name_ko, name->>'en' as name_en
FROM brands;

-- 카테고리 확인
SELECT slug, name->>'ko' as name_ko, level
FROM product_categories
ORDER BY display_order;
```

## 8. Storage 사용 예시

### 브랜드 로고 업로드

1. Supabase Dashboard → Storage → brand-images
2. "Upload file" 클릭
3. 이미지 업로드
4. Public URL 복사
5. brands 테이블의 `logo_url` 필드에 저장

### API를 통한 업로드 (프론트엔드)

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// 파일 업로드
const { data, error } = await supabase.storage
  .from('brand-images')
  .upload(`brands/${brandId}/logo.png`, file)

if (data) {
  const publicUrl = supabase.storage
    .from('brand-images')
    .getPublicUrl(data.path)

  // brands 테이블에 URL 저장
  await supabase
    .from('brands')
    .update({ logo_url: publicUrl.data.publicUrl })
    .eq('id', brandId)
}
```

## 9. RLS 정책 커스터마이징

특정 사용자만 수정 가능하도록 변경하려면:

```sql
-- 기존 정책 삭제
DROP POLICY "Authenticated users can create brands" ON brands;

-- 새 정책 생성 (admin 역할만 생성 가능)
CREATE POLICY "Only admins can create brands"
  ON brands FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.jwt() ->> 'role' = 'admin'
  );
```

## 10. 로컬 개발 (Supabase CLI)

로컬에서 Supabase 환경 복제:

```bash
# Supabase CLI 설치
npm install -g supabase

# 프로젝트 연결
cd BagInDB
supabase login
supabase link --project-ref [YOUR-PROJECT-REF]

# 로컬 환경 시작
supabase start

# 마이그레이션 적용
supabase db reset

# 로컬 Studio 열기
supabase studio
```

로컬 연결 정보:
- **API URL**: http://localhost:54321
- **DB URL**: postgresql://postgres:postgres@localhost:54322/postgres
- **Studio**: http://localhost:54323

## 트러블슈팅

### 문제: "extension uuid-ossp does not exist"
**해결**: SQL Editor에서 `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";` 실행

### 문제: "permission denied for schema storage"
**해결**: storage 마이그레이션을 service_role로 실행하거나 Dashboard에서 버킷 수동 생성

### 문제: RLS로 인해 데이터 조회 안됨
**해결**:
1. SQL Editor에서 RLS 정책 확인
2. 일시적으로 RLS 비활성화: `ALTER TABLE brands DISABLE ROW LEVEL SECURITY;`
3. 정책 재설정 후 활성화

### 문제: 마이그레이션 순서 꼬임
**해결**:
```sql
-- 모든 테이블 삭제 (주의!)
DROP TABLE IF EXISTS coffee_accessory_specs CASCADE;
DROP TABLE IF EXISTS moka_pot_specs CASCADE;
DROP TABLE IF EXISTS coffee_grinder_specs CASCADE;
DROP TABLE IF EXISTS drip_coffee_maker_specs CASCADE;
DROP TABLE IF EXISTS espresso_machine_specs CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS brands CASCADE;

-- 처음부터 마이그레이션 재실행
```

## 참고 자료

- [Supabase 공식 문서](https://supabase.com/docs)
- [Supabase RLS 가이드](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Storage 가이드](https://supabase.com/docs/guides/storage)
- [PostgreSQL JSONB 문서](https://www.postgresql.org/docs/current/datatype-json.html)
