-- ==============================================
-- 제품 스펙 테이블들
-- ==============================================

-- ----------------------------------------------
-- 에스프레소 머신 스펙
-- ----------------------------------------------

CREATE TABLE espresso_machine_specs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,

  -- 기본 스펙
  machine_type TEXT,
  boiler_type TEXT,
  boiler_material TEXT,
  boiler_capacity_ml INTEGER,

  -- 압력 및 온도
  pump_type TEXT,
  pump_pressure_bar DECIMAL(4,1),
  brew_temperature_celsius DECIMAL(4,1),
  temperature_stability TEXT,

  -- 추출 기능
  group_heads INTEGER DEFAULT 1,
  portafilter_size_mm INTEGER,
  pre_infusion BOOLEAN DEFAULT false,
  pressure_profiling BOOLEAN DEFAULT false,

  -- 스팀/온수
  steam_wand BOOLEAN DEFAULT true,
  steam_wand_type TEXT,
  hot_water_dispenser BOOLEAN DEFAULT false,

  -- 용량 및 크기
  water_tank_capacity_l DECIMAL(3,1),
  bean_hopper_capacity_g INTEGER,
  drip_tray_capacity_ml INTEGER,

  -- 물리적 사양
  dimensions_mm JSONB,
  weight_kg DECIMAL(4,1),

  -- 전력
  power_watts INTEGER,
  voltage TEXT,

  -- 추가 기능
  built_in_grinder BOOLEAN DEFAULT false,
  grinder_type TEXT,
  programmable_shots BOOLEAN DEFAULT false,
  dual_boiler BOOLEAN DEFAULT false,
  cup_warmer BOOLEAN DEFAULT false,

  -- 유지보수
  descaling_alert BOOLEAN DEFAULT false,
  water_filter_compatible BOOLEAN DEFAULT false,
  removable_brew_unit BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_espresso_specs_product ON espresso_machine_specs(product_id);
CREATE INDEX idx_espresso_specs_type ON espresso_machine_specs(machine_type);

CREATE TRIGGER set_espresso_specs_updated_at
BEFORE UPDATE ON espresso_machine_specs
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();


-- ----------------------------------------------
-- 드립 커피 메이커 스펙
-- ----------------------------------------------

CREATE TABLE drip_coffee_maker_specs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,

  -- 기본 스펙
  brew_method TEXT,
  carafe_type TEXT,
  carafe_capacity_cups INTEGER,
  carafe_capacity_ml INTEGER,

  -- 추출 기능
  brew_temperature_celsius DECIMAL(4,1),
  brew_time_minutes INTEGER,
  pause_and_serve BOOLEAN DEFAULT false,
  programmable BOOLEAN DEFAULT false,
  auto_shutoff BOOLEAN DEFAULT false,

  -- 필터
  filter_type TEXT,
  filter_size TEXT,

  -- 온도 유지
  heating_plate BOOLEAN DEFAULT false,
  heating_plate_temp_control BOOLEAN DEFAULT false,

  -- 물리적 사양
  dimensions_mm JSONB,
  weight_kg DECIMAL(4,1),

  -- 전력
  power_watts INTEGER,
  voltage TEXT,

  -- 추가 기능
  water_level_indicator BOOLEAN DEFAULT true,
  anti_drip_system BOOLEAN DEFAULT false,
  cord_storage BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_drip_specs_product ON drip_coffee_maker_specs(product_id);

CREATE TRIGGER set_drip_specs_updated_at
BEFORE UPDATE ON drip_coffee_maker_specs
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();


-- ----------------------------------------------
-- 커피 그라인더 스펙
-- ----------------------------------------------

CREATE TABLE coffee_grinder_specs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,

  -- 기본 스펙
  grinder_type TEXT NOT NULL,
  burr_type TEXT,
  burr_size_mm INTEGER,

  -- 분쇄 설정
  grind_settings INTEGER,
  grind_range TEXT,
  stepless_adjustment BOOLEAN DEFAULT false,

  -- 용량
  bean_hopper_capacity_g INTEGER,
  ground_coffee_capacity_g INTEGER,

  -- 성능
  grinding_speed_g_per_sec DECIMAL(4,1),
  motor_power_watts INTEGER,
  motor_speed_rpm INTEGER,
  noise_level_db INTEGER,

  -- 투약
  dosing_type TEXT,
  programmable_doses BOOLEAN DEFAULT false,

  -- 물리적 사양
  dimensions_mm JSONB,
  weight_kg DECIMAL(4,1),

  -- 전력
  power_watts INTEGER,
  voltage TEXT,

  -- 추가 기능
  anti_static BOOLEAN DEFAULT false,
  grind_retention_g DECIMAL(3,1),
  portafilter_holder BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_grinder_specs_product ON coffee_grinder_specs(product_id);
CREATE INDEX idx_grinder_specs_type ON coffee_grinder_specs(grinder_type);

CREATE TRIGGER set_grinder_specs_updated_at
BEFORE UPDATE ON coffee_grinder_specs
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();


-- ----------------------------------------------
-- 모카포트 스펙
-- ----------------------------------------------

CREATE TABLE moka_pot_specs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,

  -- 기본 스펙
  capacity_ml INTEGER,
  capacity_cups INTEGER,

  -- 재질
  body_material TEXT,
  chamber_material TEXT,
  gasket_material TEXT,

  -- 호환성
  heat_sources TEXT[],
  induction_compatible BOOLEAN DEFAULT false,

  -- 압력
  brewing_pressure_bar DECIMAL(3,1),
  safety_valve BOOLEAN DEFAULT true,

  -- 물리적 사양
  dimensions_mm JSONB,
  weight_g INTEGER,

  -- 부품
  replaceable_gasket BOOLEAN DEFAULT true,
  replaceable_filter BOOLEAN DEFAULT true,

  -- 추출
  brew_time_minutes INTEGER,
  grind_size_recommendation TEXT,

  -- 유지보수
  dishwasher_safe BOOLEAN DEFAULT false,
  hand_wash_only BOOLEAN DEFAULT true,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_moka_specs_product ON moka_pot_specs(product_id);

CREATE TRIGGER set_moka_specs_updated_at
BEFORE UPDATE ON moka_pot_specs
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();


-- ----------------------------------------------
-- 커피 액세서리 스펙
-- ----------------------------------------------

CREATE TABLE coffee_accessory_specs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,

  -- 액세서리 타입
  accessory_type TEXT NOT NULL,

  -- 브루잉 도구 관련
  brewing_method TEXT,
  capacity_ml INTEGER,
  capacity_cups INTEGER,

  -- 드리퍼 관련
  dripper_type TEXT,
  dripper_size TEXT,

  -- 재질
  material TEXT,
  material_details JSONB,

  -- 필터 관련
  filter_type TEXT,
  filter_included BOOLEAN DEFAULT false,
  replacement_filter_needed BOOLEAN DEFAULT false,
  filter_compatibility TEXT,

  -- 물리적 사양
  dimensions_mm JSONB,
  weight_g INTEGER,

  -- 온도 관련
  heat_source_required BOOLEAN DEFAULT false,
  heat_resistant BOOLEAN DEFAULT false,
  max_temperature_celsius INTEGER,

  -- 탬퍼 관련
  tamper_diameter_mm DECIMAL(4,1),
  tamper_base_type TEXT,
  tamper_handle_material TEXT,
  tamper_weight_g INTEGER,

  -- 밀크 피처 관련
  pitcher_spout_type TEXT,
  pitcher_capacity_ml INTEGER,

  -- 스케일 관련
  scale_max_weight_g INTEGER,
  scale_accuracy_g DECIMAL(3,1),
  scale_has_timer BOOLEAN DEFAULT false,
  scale_auto_shutoff BOOLEAN DEFAULT false,
  scale_units TEXT[],

  -- 필터/소모품 관련
  consumable_type TEXT,
  package_quantity INTEGER,

  -- 세척 도구 관련
  cleaning_tool_type TEXT,

  -- 호환성
  compatible_with TEXT[],

  -- 브루잉 사양
  brew_time_minutes INTEGER,
  grind_size_recommendation TEXT,

  -- 추가 기능
  dishwasher_safe BOOLEAN DEFAULT false,
  bpa_free BOOLEAN DEFAULT true,
  insulated BOOLEAN DEFAULT false,
  double_walled BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_accessory_specs_product ON coffee_accessory_specs(product_id);
CREATE INDEX idx_accessory_specs_type ON coffee_accessory_specs(accessory_type);
CREATE INDEX idx_accessory_specs_brewing ON coffee_accessory_specs(brewing_method);
CREATE INDEX idx_accessory_specs_dripper ON coffee_accessory_specs(dripper_type);

CREATE TRIGGER set_accessory_specs_updated_at
BEFORE UPDATE ON coffee_accessory_specs
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
