-- ==============================================
-- Row Level Security (RLS) Policies
-- ==============================================

-- Enable RLS on all tables
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE espresso_machine_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE drip_coffee_maker_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE coffee_grinder_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE moka_pot_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE coffee_accessory_specs ENABLE ROW LEVEL SECURITY;

-- ==============================================
-- Brands Policies
-- ==============================================

-- Public read access for active brands
CREATE POLICY "Brands are viewable by everyone"
  ON brands FOR SELECT
  USING (is_active = true);

-- Authenticated users can create brands
CREATE POLICY "Authenticated users can create brands"
  ON brands FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Authenticated users can update brands
CREATE POLICY "Authenticated users can update brands"
  ON brands FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Only admins can delete brands (implement with service role)
CREATE POLICY "Service role can delete brands"
  ON brands FOR DELETE
  TO service_role
  USING (true);

-- ==============================================
-- Product Categories Policies
-- ==============================================

-- Public read access for active categories
CREATE POLICY "Categories are viewable by everyone"
  ON product_categories FOR SELECT
  USING (is_active = true);

-- Authenticated users can manage categories
CREATE POLICY "Authenticated users can create categories"
  ON product_categories FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update categories"
  ON product_categories FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role can delete categories"
  ON product_categories FOR DELETE
  TO service_role
  USING (true);

-- ==============================================
-- Products Policies
-- ==============================================

-- Public read access for all products
CREATE POLICY "Products are viewable by everyone"
  ON products FOR SELECT
  USING (true);

-- Authenticated users can create products
CREATE POLICY "Authenticated users can create products"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Authenticated users can update products
CREATE POLICY "Authenticated users can update products"
  ON products FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Service role can delete products
CREATE POLICY "Service role can delete products"
  ON products FOR DELETE
  TO service_role
  USING (true);

-- ==============================================
-- Spec Tables Policies (same pattern for all)
-- ==============================================

-- Espresso Machine Specs
CREATE POLICY "Espresso specs are viewable by everyone"
  ON espresso_machine_specs FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage espresso specs"
  ON espresso_machine_specs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Drip Coffee Maker Specs
CREATE POLICY "Drip specs are viewable by everyone"
  ON drip_coffee_maker_specs FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage drip specs"
  ON drip_coffee_maker_specs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Coffee Grinder Specs
CREATE POLICY "Grinder specs are viewable by everyone"
  ON coffee_grinder_specs FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage grinder specs"
  ON coffee_grinder_specs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Moka Pot Specs
CREATE POLICY "Moka specs are viewable by everyone"
  ON moka_pot_specs FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage moka specs"
  ON moka_pot_specs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Coffee Accessory Specs
CREATE POLICY "Accessory specs are viewable by everyone"
  ON coffee_accessory_specs FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage accessory specs"
  ON coffee_accessory_specs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
