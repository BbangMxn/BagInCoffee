-- ==============================================
-- Seed Data for Development
-- ==============================================

-- Sample Brands
INSERT INTO brands (slug, name, description, headquarters, country, founded_date, specialization, verified, featured) VALUES
(
  'la-marzocco',
  '{"ko": "라마르조코", "en": "La Marzocco", "ja": "ラ・マルゾッコ", "it": "La Marzocco"}'::jsonb,
  '{"ko": "1927년 이탈리아 피렌체에서 설립된 세계적인 에스프레소 머신 제조사입니다.", "en": "World-renowned espresso machine manufacturer founded in Florence, Italy in 1927.", "ja": "1927年にイタリアのフィレンツェで設立された世界的なエスプレッソマシンメーカーです。"}'::jsonb,
  '{"ko": "이탈리아 피렌체", "en": "Florence, Italy", "ja": "イタリア・フィレンツェ"}'::jsonb,
  'IT',
  '1927-04-05',
  ARRAY['espresso_machine'],
  true,
  true
),
(
  'hario',
  '{"ko": "하리오", "en": "Hario", "ja": "ハリオ"}'::jsonb,
  '{"ko": "1921년 일본에서 설립된 유리 및 커피 기구 전문 제조사입니다.", "en": "Japanese manufacturer of glassware and coffee equipment founded in 1921.", "ja": "1921年に設立された日本のガラス製品とコーヒー器具メーカーです。"}'::jsonb,
  '{"ko": "일본 도쿄", "en": "Tokyo, Japan", "ja": "日本・東京"}'::jsonb,
  'JP',
  '1921-01-01',
  ARRAY['dripper', 'coffee_accessory'],
  true,
  true
),
(
  'comandante',
  '{"ko": "코만단테", "en": "Comandante", "ja": "コマンダンテ"}'::jsonb,
  '{"ko": "독일의 프리미엄 수동 그라인더 제조사입니다.", "en": "German manufacturer of premium manual coffee grinders.", "ja": "ドイツのプレミアム手動グラインダーメーカーです。"}'::jsonb,
  '{"ko": "독일", "en": "Germany", "ja": "ドイツ"}'::jsonb,
  'DE',
  '2010-01-01',
  ARRAY['grinder'],
  true,
  true
),
(
  'bialetti',
  '{"ko": "비알레티", "en": "Bialetti", "ja": "ビアレッティ"}'::jsonb,
  '{"ko": "1919년 이탈리아에서 설립된 모카포트의 원조 브랜드입니다.", "en": "Italian brand founded in 1919, creator of the iconic Moka pot.", "ja": "1919年にイタリアで設立されたモカポットの創始者です。"}'::jsonb,
  '{"ko": "이탈리아", "en": "Italy", "ja": "イタリア"}'::jsonb,
  'IT',
  '1919-01-01',
  ARRAY['moka_pot', 'coffee_accessory'],
  true,
  true
);

-- Sample Categories
INSERT INTO product_categories (slug, name, description, level, spec_table_name, display_order) VALUES
(
  'espresso-machines',
  '{"ko": "에스프레소 머신", "en": "Espresso Machines", "ja": "エスプレッソマシン"}'::jsonb,
  '{"ko": "가정용부터 상업용까지 다양한 에스프레소 머신", "en": "Espresso machines from home to commercial use", "ja": "家庭用から業務用まで様々なエスプレッソマシン"}'::jsonb,
  0,
  'espresso_machine_specs',
  1
),
(
  'coffee-grinders',
  '{"ko": "커피 그라인더", "en": "Coffee Grinders", "ja": "コーヒーグラインダー"}'::jsonb,
  '{"ko": "수동 및 전동 커피 그라인더", "en": "Manual and electric coffee grinders", "ja": "手動および電動コーヒーグラインダー"}'::jsonb,
  0,
  'coffee_grinder_specs',
  2
),
(
  'drip-coffee-makers',
  '{"ko": "드립 커피 메이커", "en": "Drip Coffee Makers", "ja": "ドリップコーヒーメーカー"}'::jsonb,
  '{"ko": "자동 드립 커피 메이커", "en": "Automatic drip coffee makers", "ja": "自動ドリップコーヒーメーカー"}'::jsonb,
  0,
  'drip_coffee_maker_specs',
  3
),
(
  'moka-pots',
  '{"ko": "모카포트", "en": "Moka Pots", "ja": "モカポット"}'::jsonb,
  '{"ko": "스토브탑 에스프레소 메이커", "en": "Stovetop espresso makers", "ja": "ストーブトップエスプレッソメーカー"}'::jsonb,
  0,
  'moka_pot_specs',
  4
),
(
  'coffee-accessories',
  '{"ko": "커피 액세서리", "en": "Coffee Accessories", "ja": "コーヒーアクセサリー"}'::jsonb,
  '{"ko": "드리퍼, 탬퍼, 피처, 스케일 등", "en": "Drippers, tampers, pitchers, scales, and more", "ja": "ドリッパー、タンパー、ピッチャー、スケールなど"}'::jsonb,
  0,
  'coffee_accessory_specs',
  5
);

-- Note: Product examples would be added here with corresponding spec entries
-- but keeping this minimal for initial setup

DO $$
BEGIN
  RAISE NOTICE '✅ Seed data inserted successfully!';
  RAISE NOTICE 'Created:';
  RAISE NOTICE '  - 4 brands (La Marzocco, Hario, Comandante, Bialetti)';
  RAISE NOTICE '  - 5 product categories';
END $$;
