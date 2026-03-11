-- ==============================================
-- 제품 가격 정보 테이블 추가
-- 작성일: 2025-01-09
-- ==============================================

-- 제품 가격 테이블 생성
CREATE TABLE product_pricing (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,

  -- 가격 정보
  currency VARCHAR(3) DEFAULT 'USD',
  min_price NUMERIC(10, 2),
  max_price NUMERIC(10, 2),
  msrp NUMERIC(10, 2), -- Manufacturer's Suggested Retail Price

  -- 시장 정보
  market VARCHAR(50), -- 'US', 'KR', 'JP', 'EU' 등
  price_type VARCHAR(50), -- 'retail', 'wholesale', 'online', 'used' 등

  -- 유효 기간
  valid_from DATE DEFAULT CURRENT_DATE,
  valid_until DATE,

  -- 출처 및 메타 정보
  source TEXT, -- 가격 정보 출처
  notes TEXT,
  is_current BOOLEAN DEFAULT true,

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 코멘트 추가
COMMENT ON TABLE product_pricing IS 'Product pricing information with market and time tracking';

-- 인덱스 생성
CREATE INDEX idx_product_pricing_product_id ON product_pricing(product_id);
CREATE INDEX idx_product_pricing_market ON product_pricing(market);
CREATE INDEX idx_product_pricing_is_current ON product_pricing(is_current);
CREATE INDEX idx_product_pricing_valid_from ON product_pricing(valid_from);
CREATE INDEX idx_product_pricing_valid_until ON product_pricing(valid_until);

-- 트리거 설정
CREATE TRIGGER set_product_pricing_updated_at
BEFORE UPDATE ON product_pricing
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DO $$
BEGIN
  RAISE NOTICE '✅ 제품 가격 테이블이 추가되었습니다!';
END $$;
