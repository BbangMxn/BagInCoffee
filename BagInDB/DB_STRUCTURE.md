# Database Structure - Equipment Database

## Overview
이 데이터베이스는 커피 장비 및 액세서리에 대한 정보를 저장하는 Supabase 프로젝트입니다.
- **Project Name**: Equipment
- **Project ID**: naizypxglszbxemqnouv
- **Region**: ap-southeast-1
- **Status**: ACTIVE_HEALTHY

---

## Tables

### 1. brands
브랜드 정보를 저장하는 테이블

**Primary Key**: `id` (uuid)

**Columns**:
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | uuid_generate_v4() | 브랜드 고유 ID |
| slug | text | NO | - | URL용 슬러그 (unique) |
| name | jsonb | NO | - | 다국어 이름 (en, ko 필수) |
| description | jsonb | YES | - | 다국어 설명 |
| headquarters | jsonb | YES | - | 본사 정보 |
| logo_url | text | YES | - | 로고 이미지 URL |
| images | text[] | YES | - | 이미지 URL 배열 |
| website | text | YES | - | 공식 웹사이트 |
| country | text | YES | - | 국가 |
| founded_date | date | YES | - | 설립일 |
| founded_year | integer | YES | EXTRACT(year FROM founded_date) | 설립 연도 (자동 생성) |
| specialization | text[] | YES | - | 전문 분야 |
| is_active | boolean | YES | true | 활성 상태 |
| featured | boolean | YES | false | 추천 브랜드 여부 |
| verified | boolean | YES | false | 검증 여부 |
| available_locales | text[] | YES | ['ko', 'en'] | 사용 가능한 언어 |
| default_locale | text | YES | 'en' | 기본 언어 |
| created_at | timestamptz | YES | now() | 생성 시간 |
| updated_at | timestamptz | YES | now() | 수정 시간 |

**Features**:
- RLS 활성화
- 총 67개 레코드

---

### 2. product_categories
제품 카테고리를 계층적으로 저장하는 테이블

**Primary Key**: `id` (uuid)

**Columns**:
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | uuid_generate_v4() | 카테고리 고유 ID |
| slug | varchar | NO | - | URL용 슬러그 (unique) |
| parent_id | uuid | YES | - | 부모 카테고리 ID (self-reference) |
| level | integer | NO | 0 | 계층 레벨 (0=최상위) |
| path | text | YES | - | 계층 경로 |
| name | jsonb | NO | - | 다국어 이름 (en, ko 필수) |
| description | jsonb | YES | - | 다국어 설명 |
| spec_table_name | text | YES | - | 스펙 테이블 이름 (deprecated) |
| icon_url | text | YES | - | 아이콘 URL |
| image_url | text | YES | - | 이미지 URL |
| product_count | integer | YES | 0 | 제품 수 |
| display_order | integer | YES | 0 | 표시 순서 |
| is_active | boolean | YES | true | 활성 상태 |
| is_accessory | boolean | YES | false | 액세서리 여부 |
| created_at | timestamptz | YES | now() | 생성 시간 |
| updated_at | timestamptz | YES | now() | 수정 시간 |

**Features**:
- RLS 활성화
- 총 34개 레코드
- 계층 구조 지원 (parent_id → id)

**Category Hierarchy**:

```
coffee-equipment (Level 0)
├── espresso-machines (Level 1)
│   ├── tampers (Level 2, accessory)
│   ├── portafilters (Level 2, accessory)
│   ├── filter-baskets (Level 2, accessory)
│   └── distribution-tools (Level 2, accessory)
├── coffee-grinders (Level 1)
│   ├── bellows (Level 2, accessory)
│   └── dosing-cups (Level 2, accessory)
├── drip-coffee-makers (Level 1)
├── pour-over (Level 1)
│   ├── hand-drip (Level 2)
│   │   ├── hario-v60 (Level 3)
│   │   ├── kalita-wave (Level 3)
│   │   ├── chemex (Level 3)
│   │   ├── kono (Level 3)
│   │   ├── clever-dripper (Level 3)
│   │   ├── melitta (Level 3)
│   │   └── other-drippers (Level 3)
│   ├── drippers (Level 2, accessory)
│   ├── servers (Level 2, accessory)
│   └── filter-papers (Level 2, accessory)
├── immersion-brewers (Level 1)
│   ├── french-press (Level 2)
│   ├── aeropress (Level 2)
│   └── siphon (Level 2)
├── moka-pots (Level 1)
│   ├── gaskets (Level 2, accessory)
│   └── replacement-filters (Level 2, accessory)
├── cold-brew (Level 1)
├── scales (Level 1)
├── kettles (Level 1)
└── milk-equipment (Level 1)

coffee-accessories (Level 0)
```

---

### 3. products
제품 정보를 저장하는 메인 테이블 (통합 스펙 포함)

**Primary Key**: `id` (uuid)

**Columns**:
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | uuid_generate_v4() | 제품 고유 ID |
| slug | text | NO | - | URL용 슬러그 (unique) |
| category_id | uuid | NO | - | 카테고리 ID (FK) |
| brand_id | uuid | NO | - | 브랜드 ID (FK) |
| name | jsonb | NO | - | 다국어 이름 (en, ko 필수) |
| description | jsonb | YES | - | 다국어 설명 |
| model_number | text | YES | - | 모델 번호 |
| identifiers | jsonb | YES | - | 식별자 정보 |
| image_url | text | YES | - | 대표 이미지 URL |
| images | text[] | YES | - | 이미지 URL 배열 |
| manufacturer_country | char | YES | - | 제조 국가 |
| release_date | date | YES | - | 출시일 |
| discontinued_date | date | YES | - | 단종일 |
| view_count | integer | YES | 0 | 조회수 |
| edit_count | integer | YES | 0 | 수정 횟수 |
| is_verified | boolean | YES | false | 검증 여부 |
| available_locales | text[] | YES | ['ko', 'en'] | 사용 가능한 언어 |
| default_locale | text | YES | 'en' | 기본 언어 |
| created_at | timestamptz | YES | now() | 생성 시간 |
| updated_at | timestamptz | YES | now() | 수정 시간 |
| purchase_links | jsonb | YES | '[]' | 구매 링크 배열 |
| official_url | text | YES | - | 공식 제품 페이지 URL |
| dimensions | jsonb | YES | - | 물리적 치수 {width_mm, height_mm, depth_mm} |
| weight | jsonb | YES | - | 무게 {value, unit} |
| power_watts | integer | YES | - | 전력 (와트) |
| voltage | text | YES | - | 전압 |
| **specs** | **jsonb** | **YES** | **'{}'** | **카테고리별 상세 스펙 (JSONB)** |
| current_price_min | numeric | YES | - | 현재 최저 가격 |
| current_price_max | numeric | YES | - | 현재 최고 가격 |
| current_price_currency | varchar | YES | 'USD' | 통화 코드 |
| current_price_updated_at | timestamptz | YES | - | 가격 업데이트 시간 |

**Features**:
- RLS 활성화
- 총 60개 레코드
- **specs 컬럼에 카테고리별 스펙이 JSONB로 저장됨**

---

### 4. product_pricing
제품 가격 정보를 저장하는 테이블

**Primary Key**: `id` (uuid)

**Columns**:
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | uuid_generate_v4() | 가격 정보 고유 ID |
| product_id | uuid | NO | - | 제품 ID (FK) |
| currency | varchar | YES | 'USD' | 통화 코드 |
| min_price | numeric | YES | - | 최저 가격 |
| max_price | numeric | YES | - | 최고 가격 |
| msrp | numeric | YES | - | 권장 소비자 가격 |
| market | varchar | YES | - | 시장 (지역) |
| price_type | varchar | YES | - | 가격 유형 |
| valid_from | date | YES | CURRENT_DATE | 유효 시작일 |
| valid_until | date | YES | - | 유효 종료일 |
| source | text | YES | - | 출처 |
| notes | text | YES | - | 참고사항 |
| is_current | boolean | YES | true | 현재 가격 여부 |
| marketplace | text | YES | - | 마켓플레이스 (amazon, aliexpress 등) |
| created_at | timestamptz | YES | now() | 생성 시간 |
| updated_at | timestamptz | YES | now() | 수정 시간 |

**Features**:
- RLS 활성화
- 총 28개 레코드
- 시장별, 시간별 가격 추적 가능

---

## Category-Specific Specifications (products.specs JSONB)

각 카테고리별로 `products.specs` 컬럼에 저장되는 스펙 필드입니다.

### Coffee Grinders (coffee-grinders)

```json
{
  "voltage": "110V/220V",
  "burr_type": "flat|conical",
  "rpm_range": {"min": 300, "max": 1400},
  "weight_kg": 2.7,
  "motor_type": "bldc|dc-motor",
  "anti_static": true,
  "dosing_type": "manual|on-demand|weight-based|timed|timed-manual",
  "grind_range": "espresso-filter|espresso-only|pour-over-only|full-range|turkish-cold-brew",
  "handle_type": "foldable|oak-wood|wood-knob",
  "power_watts": 150,
  "single_dose": true,
  "burr_size_mm": 64,
  "grinder_type": "manual|electric|burr",
  "body_material": "aluminum|stainless-steel|aluminum-alloy",
  "burr_material": "steel|ssp-steel|titanium-coated|dlc-coated-steel|nitro-blade-steel",
  "dimensions_mm": {"width": 114, "height": 295, "depth": 178},
  "grind_settings": 999,
  "noise_level_db": 75,
  "timed_grinding": false,
  "grinding_effort": "medium",
  "handle_material": "aluminum|oak-stainless|wood-aluminum",
  "heat_generation": null,
  "motor_speed_rpm": 1400,
  "travel_friendly": false,
  "cup_clearance_mm": null,
  "display_features": ["grind-indicator", "touchscreen", "rpm", "weight", "timer"],
  "dosing_accuracy_g": null,
  "grind_retention_g": 0.1,
  "motor_power_watts": 150,
  "grind_speed_rating": null,
  "grinding_mechanism": null,
  "portafilter_holder": true,
  "programmable_doses": false,
  "clicks_per_rotation": 90,
  "stepless_adjustment": true,
  "weight_based_grinding": true,
  "bean_hopper_capacity_g": 50,
  "portafilter_fork_sizes": [58],
  "grind_consistency_rating": "excellent|very-good",
  "grinding_speed_g_per_sec": 2.0,
  "ground_coffee_capacity_g": 50,
  "adjustment_per_click_microns": 8
}
```

### Espresso Machines (espresso-machines)

```json
{
  "voltage": "110-220V",
  "pump_type": "vibration|rotary|manual-lever|manual-piston",
  "weight_kg": 13.1,
  "cup_warmer": true,
  "steam_wand": true,
  "boiler_type": "single|dual|heat-exchanger|thermoblock|none",
  "dual_boiler": true,
  "group_heads": 1,
  "power_watts": 1600,
  "connectivity": ["bluetooth", "app"],
  "display_type": "lcd|digital|analog-pressure-gauge",
  "grinder_type": "burr",
  "machine_type": "semi-automatic|manual|manual-lever|manual-portable",
  "pre_infusion": true,
  "water_source": null,
  "dimensions_mm": {"width": 325, "height": 405, "depth": 315},
  "boiler_material": "aluminum|brass|stainless-steel|copper",
  "descaling_alert": false,
  "steam_wand_type": "automatic|manual|cool-touch-performance|no-burn-stainless|manual-2-hole",
  "built_in_grinder": true,
  "pre_infusion_type": "programmable|e61-mechanical",
  "pump_pressure_bar": 15,
  "boiler_capacity_ml": 1600,
  "pressure_profiling": true,
  "programmable_shots": true,
  "hot_water_dispenser": true,
  "portafilter_size_mm": 58,
  "removable_brew_unit": false,
  "drip_tray_capacity_ml": null,
  "pressure_profile_type": "paddle|manual-lever",
  "temperature_stability": "PID|thermosiphon",
  "water_tank_capacity_l": 2.0,
  "bean_hopper_capacity_g": null,
  "brew_temp_range_celsius": {"min": 85, "max": 100},
  "water_filter_compatible": true,
  "brew_temperature_celsius": 93,
  "temperature_control_type": "dual-pid|dual-pid-lcc|thermostat",
  "pre_infusion_duration_seconds": null
}
```

### Drip Coffee Makers (drip-coffee-makers)

```json
{
  "voltage": "110-120V",
  "weight_kg": 4.4,
  "brew_modes": ["pour-over", "fast", "cold-brew"],
  "brew_method": "precision-auto|auto-pour-over|auto-drip",
  "carafe_type": "thermal|glass-thermal",
  "filter_size": "#2-flat-dual|#4|chemex",
  "filter_type": "paper|paper-cone|chemex",
  "power_watts": 1700,
  "auto_shutoff": true,
  "cord_storage": false,
  "pre_infusion": true,
  "programmable": true,
  "clock_display": true,
  "dimensions_mm": {"width": 227, "height": 305, "depth": 227},
  "heating_plate": false,
  "hold_function": false,
  "sca_certified": true,
  "carafe_material": "stainless-steel|borosilicate-glass",
  "pause_and_serve": true,
  "anti_drip_system": false,
  "auto_clean_cycle": false,
  "brew_basket_type": "flat-cone-dual|flat-bottom|cone",
  "carafe_insulated": true,
  "shower_head_type": "precision-spray|precision-bloom|multi-hole",
  "brew_time_minutes": 7,
  "pre_infusion_type": "bloom",
  "carafe_capacity_ml": 1500,
  "temp_range_celsius": {"min": 90, "max": 96},
  "temperature_control": true,
  "carafe_capacity_cups": 10,
  "removable_water_tank": true,
  "brew_strength_control": true,
  "hold_duration_minutes": null,
  "water_filter_included": false,
  "water_level_indicator": true,
  "brew_temperature_celsius": 200,
  "hold_temperature_celsius": null,
  "permanent_filter_included": false,
  "heating_plate_temp_control": false,
  "water_distribution_quality": null
}
```

### Moka Pots (moka-pots)

```json
{
  "finish": "polished",
  "voltage": null,
  "electric": false,
  "weight_g": 750,
  "spout_type": null,
  "valve_type": null,
  "capacity_ml": 270,
  "crema_valve": false,
  "power_watts": null,
  "auto_shutoff": false,
  "design_style": "classic|modern|modern-design",
  "heat_sources": ["gas", "electric", "induction"],
  "safety_valve": true,
  "body_material": "aluminum|stainless-steel-18-10",
  "capacity_cups": 6,
  "dimensions_mm": {"height": 220, "base_diameter": 115},
  "hand_wash_only": true,
  "warranty_years": 2,
  "dishwasher_safe": false,
  "gasket_material": "silicone",
  "handle_material": "nylon|acrylic|cast-iron",
  "made_in_country": null,
  "total_height_mm": 220,
  "base_diameter_mm": 115,
  "chamber_material": "aluminum|stainless-steel",
  "ergonomic_handle": false,
  "transparent_knob": false,
  "brew_time_minutes": 5,
  "replaceable_filter": true,
  "replaceable_gasket": true,
  "brewing_pressure_bar": 2,
  "induction_compatible": true,
  "handle_heat_resistant": true,
  "grind_size_recommendation": "fine-medium|fine-espresso"
}
```

### Coffee Accessories (coffee-accessories)

포괄적인 액세서리 스펙으로 다양한 타입을 지원:

```json
{
  "voltage": "120V/220V",
  "bpa_free": true,
  "material": "ceramic-porcelain|304-stainless-steel|aluminum-silicone|abs-silicone|stainless-steel-aluminum",
  "weight_g": 200,
  "insulated": false,
  "hole_count": 1,
  "rib_design": "spiral-ridges",
  "capacity_ml": 700,
  "filter_type": "paper-cone|paper-bonded|micro-paper",
  "kettle_type": "electric",
  "power_watts": 1200,
  "scale_timer": true,
  "scale_units": ["g", "oz"],
  "dripper_size": "02",
  "dripper_type": "cone-60|chemex|v60",
  "hole_pattern": "single-large",
  "capacity_cups": 4,
  "dimensions_mm": {"width": 120, "height": 145, "depth": 102},
  "double_walled": false,
  "accessory_type": "dripper|kettle|scale|tamper|storage",
  "brewing_method": "pour-over|aeropress",
  "heat_resistant": true,
  "kettle_presets": null,
  "compatible_with": null,
  "consumable_type": null,
  "dishwasher_safe": true,
  "filter_included": false,
  "kettle_cordless": true,
  "scale_bluetooth": true,
  "scale_has_timer": false,
  "tamper_weight_g": 375,
  "kettle_base_type": "360-degree",
  "kettle_gooseneck": true,
  "material_details": null,
  "package_quantity": null,
  "scale_accuracy_g": 0.1,
  "scale_auto_timer": true,
  "tamper_base_type": "flat-stepped",
  "brew_time_minutes": null,
  "hybrid_compatible": false,
  "scale_precision_g": 0.1,
  "tamper_calibrated": false,
  "cleaning_tool_type": null,
  "cone_angle_degrees": 60,
  "kettle_heat_source": ["electric"],
  "pitcher_spout_type": null,
  "scale_auto_shutoff": false,
  "scale_battery_type": "li-ion|li-ion-1600mah",
  "scale_display_type": "led-8digit|led-hidden",
  "scale_max_weight_g": 2000,
  "scale_rechargeable": true,
  "scale_resolution_g": 0.01,
  "tamper_diameter_mm": 58.6,
  "kettle_display_type": "lcd-digital",
  "kettle_temp_control": true,
  "pitcher_capacity_ml": null,
  "pitcher_thermometer": false,
  "scale_tare_function": true,
  "tamper_depth_marker": false,
  "filter_compatibility": "v60-02-cone|chemex-square",
  "heat_source_required": false,
  "kettle_hold_function": true,
  "scale_app_compatible": true,
  "tamper_base_material": "440c-stainless",
  "tamper_self_leveling": false,
  "tamper_spring_loaded": false,
  "kettle_temp_precision": 0.5,
  "scale_water_resistant": true,
  "scale_platform_size_mm": {"width": 105, "depth": 105},
  "scale_response_time_ms": 20,
  "tamper_handle_material": "aluminum-wood-powder-coat",
  "tamper_height_range_mm": {"min": 85, "max": 92},
  "max_temperature_celsius": 120,
  "pitcher_volume_markings": false,
  "kettle_boil_time_seconds": 180,
  "scale_battery_life_hours": 35,
  "tamper_adjustable_height": true,
  "grind_size_recommendation": null,
  "kettle_temp_range_celsius": {"min": 40, "max": 100},
  "pitcher_non_stick_coating": false,
  "replacement_filter_needed": true,
  "scale_battery_capacity_mah": 1100,
  "kettle_hold_duration_minutes": 60,
  "scale_water_resistance_rating": null,
  "tamper_calibration_pressure_lbs": null,
  
  // Immersion brewers (AeroPress, French Press, Siphon)
  "type": "immersion|accessory",
  "capacity_g": 450,
  "includes_mug": true,
  "pressure_brewing": true,
  "design_style": "iconic-hourglass",
  "vacuum_seal": true,
  "date_tracker": true,
  "airtight": true
}
```

---

## Foreign Key Relationships

```
brands (id) ← products (brand_id)
product_categories (id) ← products (category_id)
product_categories (id) ← product_categories (parent_id) [self-reference]
products (id) ← product_pricing (product_id)
```

---

## Notes

1. **Specs 저장 방식**: 초기에는 카테고리별 별도 테이블(`espresso_machine_specs`, `coffee_grinder_specs` 등)을 계획했으나, 실제로는 `products.specs` JSONB 컬럼에 통합하여 저장하는 방식으로 구현되었습니다.

2. **다국어 지원**: `name`, `description` 등의 필드는 JSONB 타입으로 저장되며, 최소 `en`과 `ko` 키를 포함해야 합니다.
   ```json
   {
     "en": "English Name",
     "ko": "한국어 이름"
   }
   ```

3. **RLS (Row Level Security)**: 모든 테이블에 RLS가 활성화되어 있습니다.

4. **계층 구조**: `product_categories`는 `parent_id`를 통해 최대 3단계까지 계층 구조를 지원합니다.

5. **Accessory 플래그**: `is_accessory=true`인 카테고리는 부모 장비의 액세서리를 나타냅니다.

---

## Example Queries

### 카테고리별 제품 수 조회
```sql
SELECT 
  pc.slug,
  pc.name->>'en' as category_name,
  COUNT(p.id) as product_count
FROM product_categories pc
LEFT JOIN products p ON pc.id = p.category_id
GROUP BY pc.id, pc.slug, pc.name
ORDER BY product_count DESC;
```

### 특정 브랜드의 모든 제품 조회
```sql
SELECT 
  p.slug,
  p.name->>'en' as product_name,
  b.name->>'en' as brand_name,
  pc.name->>'en' as category_name,
  p.specs
FROM products p
JOIN brands b ON p.brand_id = b.id
JOIN product_categories pc ON p.category_id = pc.id
WHERE b.slug = 'fellow';
```

### 그라인더 스펙 조회
```sql
SELECT 
  p.name->>'en' as product_name,
  p.specs->>'burr_type' as burr_type,
  p.specs->>'burr_size_mm' as burr_size,
  p.specs->>'grinder_type' as grinder_type
FROM products p
JOIN product_categories pc ON p.category_id = pc.id
WHERE pc.slug = 'coffee-grinders'
  AND p.specs IS NOT NULL;
```
