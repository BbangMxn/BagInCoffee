-- ==============================================
-- 커피 제품 데이터베이스 스키마 (Supabase Migration)
-- 작성일: 2025-01-04
-- ==============================================

-- ==============================================
-- 1단계: 확장 기능 활성화
-- ==============================================

-- UUID 생성 기능
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 텍스트 유사도 검색 기능 (trigram)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";


-- ==============================================
-- 2단계: 공통 함수 생성
-- ==============================================

-- updated_at 컬럼 자동 갱신을 위한 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ==============================================
-- 3단계: 브랜드 테이블 (독립 테이블)
-- ==============================================

CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,

    -- 다국어 지원 필드
    name JSONB NOT NULL,
    description JSONB,
    headquarters JSONB,

    -- 이미지 관련 정보
    logo_url TEXT,
    images TEXT[],

    -- 회사 정보
    website TEXT,
    country TEXT,
    founded_date DATE,
    founded_year INTEGER GENERATED ALWAYS AS (EXTRACT(YEAR FROM founded_date)::integer) STORED,

    -- 분류/전문화 정보
    specialization TEXT[],

    -- 상태 플래그
    is_active BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false,

    -- 다국어 메타데이터
    available_locales TEXT[] DEFAULT ARRAY['ko', 'en'],
    default_locale TEXT DEFAULT 'en' CHECK (default_locale = ANY(available_locales)),

    -- 타임스탬프
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- JSONB 검증 제약조건
    CONSTRAINT check_brands_name_has_locales CHECK (name ? 'en' AND name ? 'ko')
);

-- 인덱스
CREATE INDEX idx_brands_name ON brands USING GIN (name jsonb_path_ops);
CREATE UNIQUE INDEX idx_brands_slug ON brands (slug);

-- 트리거
CREATE TRIGGER set_brands_updated_at
BEFORE UPDATE ON brands
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();


-- ==============================================
-- 4단계: 제품 카테고리 테이블
-- ==============================================

CREATE TABLE product_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug VARCHAR(100) UNIQUE NOT NULL,

  -- 계층 구조
  parent_id UUID REFERENCES product_categories(id) ON DELETE CASCADE,
  level INTEGER NOT NULL DEFAULT 0,
  path TEXT,

  -- 다국어 정보
  name JSONB NOT NULL,
  description JSONB,

  -- 스펙 테이블 매핑
  spec_table_name TEXT,

  -- 아이콘/이미지
  icon_url TEXT,
  image_url TEXT,

  -- 메타
  product_count INTEGER DEFAULT 0,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 제약조건
  CONSTRAINT check_no_self_reference CHECK (id != parent_id),
  CONSTRAINT check_level_consistency CHECK (
    (level = 0 AND parent_id IS NULL) OR
    (level > 0 AND parent_id IS NOT NULL)
  ),
  CONSTRAINT check_categories_name_has_locales CHECK (name ? 'en' AND name ? 'ko')
);

-- 인덱스
CREATE INDEX idx_categories_parent ON product_categories(parent_id);
CREATE INDEX idx_categories_slug ON product_categories(slug);
CREATE INDEX idx_categories_level ON product_categories(level);
CREATE INDEX idx_categories_path ON product_categories USING GIN(path gin_trgm_ops);

-- 트리거
CREATE TRIGGER set_categories_updated_at
BEFORE UPDATE ON product_categories
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();


-- ==============================================
-- 5단계: 제품 테이블
-- ==============================================

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,

  category_id UUID NOT NULL REFERENCES product_categories(id) ON DELETE RESTRICT,
  brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE RESTRICT,

  -- 기본 정보
  name JSONB NOT NULL,
  description JSONB,

  -- 식별자
  model_number TEXT,
  identifiers JSONB,

  -- 이미지
  image_url TEXT,
  images TEXT[],

  -- 제조 정보
  manufacturer_country CHAR(2),
  release_date DATE,
  discontinued_date DATE,

  -- 위키 메타
  view_count INTEGER DEFAULT 0,
  edit_count INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,

  -- 다국어 설정
  available_locales TEXT[] DEFAULT ARRAY['ko', 'en'],
  default_locale TEXT DEFAULT 'en',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT check_products_name_has_locales CHECK (name ? 'en' AND name ? 'ko')
);

-- 인덱스
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_name ON products USING GIN(name jsonb_path_ops);

-- 트리거
CREATE TRIGGER set_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
