-- ==============================================
-- Profiles Table and Admin-based RLS Policies
-- 작성일: 2025-01-11
-- ==============================================

-- ==============================================
-- 1단계: Profiles 테이블 생성
-- ==============================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    avatar_url TEXT,
    bio TEXT,
    location TEXT,
    website TEXT,

    -- 역할 기반 권한
    role TEXT NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'admin', 'moderator', 'subadmin')),

    -- 타임스탬프
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_role ON profiles(role);

-- RLS 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles 정책: 모든 사람이 프로필을 볼 수 있음
CREATE POLICY "Profiles are viewable by everyone"
    ON profiles FOR SELECT
    USING (true);

-- Profiles 정책: 사용자는 자신의 프로필만 수정 가능
CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Profiles 정책: 사용자는 자신의 프로필을 생성할 수 있음 (role은 기본값 'user'만 가능)
CREATE POLICY "Users can create their own profile"
    ON profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id AND role = 'user');

-- 트리거: updated_at 자동 업데이트
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ==============================================
-- 2단계: Admin 확인 헬퍼 함수
-- ==============================================

-- 현재 사용자가 admin인지 확인하는 함수
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role IN ('admin', 'subadmin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 현재 사용자가 moderator 이상인지 확인하는 함수
CREATE OR REPLACE FUNCTION is_moderator()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role IN ('admin', 'subadmin', 'moderator')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================
-- 3단계: 기존 RLS 정책 업데이트 (Admin 전용으로 변경)
-- ==============================================

-- ============ Brands 정책 업데이트 ============

-- 기존 정책 삭제
DROP POLICY IF EXISTS "Authenticated users can create brands" ON brands;
DROP POLICY IF EXISTS "Authenticated users can update brands" ON brands;
DROP POLICY IF EXISTS "Service role can delete brands" ON brands;

-- Admin만 생성 가능
CREATE POLICY "Only admins can create brands"
    ON brands FOR INSERT
    TO authenticated
    WITH CHECK (is_admin());

-- Admin만 수정 가능
CREATE POLICY "Only admins can update brands"
    ON brands FOR UPDATE
    TO authenticated
    USING (is_admin())
    WITH CHECK (is_admin());

-- Admin만 삭제 가능
CREATE POLICY "Only admins can delete brands"
    ON brands FOR DELETE
    TO authenticated
    USING (is_admin());

-- ============ Product Categories 정책 업데이트 ============

DROP POLICY IF EXISTS "Authenticated users can create categories" ON product_categories;
DROP POLICY IF EXISTS "Authenticated users can update categories" ON product_categories;
DROP POLICY IF EXISTS "Service role can delete categories" ON product_categories;

CREATE POLICY "Only admins can create categories"
    ON product_categories FOR INSERT
    TO authenticated
    WITH CHECK (is_admin());

CREATE POLICY "Only admins can update categories"
    ON product_categories FOR UPDATE
    TO authenticated
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "Only admins can delete categories"
    ON product_categories FOR DELETE
    TO authenticated
    USING (is_admin());

-- ============ Products 정책 업데이트 ============

DROP POLICY IF EXISTS "Authenticated users can create products" ON products;
DROP POLICY IF EXISTS "Authenticated users can update products" ON products;
DROP POLICY IF EXISTS "Service role can delete products" ON products;

-- Moderator 이상만 제품 생성/수정 가능
CREATE POLICY "Only moderators can create products"
    ON products FOR INSERT
    TO authenticated
    WITH CHECK (is_moderator());

CREATE POLICY "Only moderators can update products"
    ON products FOR UPDATE
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

CREATE POLICY "Only admins can delete products"
    ON products FOR DELETE
    TO authenticated
    USING (is_admin());

-- ============ Spec Tables 정책 업데이트 ============

-- Espresso Machine Specs
DROP POLICY IF EXISTS "Authenticated users can manage espresso specs" ON espresso_machine_specs;

CREATE POLICY "Only moderators can manage espresso specs"
    ON espresso_machine_specs FOR ALL
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

-- Drip Coffee Maker Specs
DROP POLICY IF EXISTS "Authenticated users can manage drip specs" ON drip_coffee_maker_specs;

CREATE POLICY "Only moderators can manage drip specs"
    ON drip_coffee_maker_specs FOR ALL
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

-- Coffee Grinder Specs
DROP POLICY IF EXISTS "Authenticated users can manage grinder specs" ON coffee_grinder_specs;

CREATE POLICY "Only moderators can manage grinder specs"
    ON coffee_grinder_specs FOR ALL
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

-- Moka Pot Specs
DROP POLICY IF EXISTS "Authenticated users can manage moka specs" ON moka_pot_specs;

CREATE POLICY "Only moderators can manage moka specs"
    ON moka_pot_specs FOR ALL
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

-- Coffee Accessory Specs
DROP POLICY IF EXISTS "Authenticated users can manage accessory specs" ON coffee_accessory_specs;

CREATE POLICY "Only moderators can manage accessory specs"
    ON coffee_accessory_specs FOR ALL
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

-- ==============================================
-- 4단계: 자동으로 프로필 생성하는 트리거
-- ==============================================

-- 새로운 사용자가 가입하면 자동으로 프로필 생성
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, role)
    VALUES (NEW.id, 'user');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- auth.users에 새 레코드가 생성되면 트리거 실행
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE handle_new_user();

-- ==============================================
-- 5단계: Product Pricing 테이블 RLS 정책 추가
-- ==============================================

-- Product Pricing 정책
CREATE POLICY "Pricing is viewable by everyone"
    ON product_pricing FOR SELECT
    USING (true);

CREATE POLICY "Only moderators can create pricing"
    ON product_pricing FOR INSERT
    TO authenticated
    WITH CHECK (is_moderator());

CREATE POLICY "Only moderators can update pricing"
    ON product_pricing FOR UPDATE
    TO authenticated
    USING (is_moderator())
    WITH CHECK (is_moderator());

CREATE POLICY "Only admins can delete pricing"
    ON product_pricing FOR DELETE
    TO authenticated
    USING (is_admin());
