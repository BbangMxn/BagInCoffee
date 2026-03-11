# BagInDB v2 - Database Schema Documentation

## Overview

BagInDB v2 uses a **unified product specification system** where all category-specific specs are stored in a single `products.specs` JSONB field. This approach provides:

- **Flexibility**: Easy to add new product categories without schema changes
- **Performance**: Single table queries instead of complex JOINs
- **Simplicity**: One source of truth for all product specifications

## Core Tables

### 1. `brands`
Stores coffee equipment brand information with multi-language support.

```sql
CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    name JSONB NOT NULL CHECK (name ? 'en' AND name ? 'ko'),
    description JSONB,
    headquarters JSONB,
    logo_url TEXT,
    images TEXT[],
    website TEXT,
    country VARCHAR(2),
    founded_date DATE,
    founded_year INTEGER GENERATED ALWAYS AS (EXTRACT(year FROM founded_date)::integer) STORED,
    specialization TEXT[],
    is_active BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false,
    available_locales TEXT[] DEFAULT ARRAY['ko', 'en'],
    default_locale TEXT DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Example Data:**
```json
{
  "slug": "fellow",
  "name": {"en": "Fellow", "ko": "펠로우"},
  "country": "US",
  "founded_year": 2013,
  "specialization": ["Grinders", "Kettles", "Accessories"]
}
```

### 2. `product_categories`
Hierarchical category structure with unlimited depth.

```sql
CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(255) UNIQUE NOT NULL,
    parent_id UUID REFERENCES product_categories(id),
    level INTEGER DEFAULT 0,
    path TEXT,
    name JSONB NOT NULL CHECK (name ? 'en' AND name ? 'ko'),
    description JSONB,
    spec_table_name TEXT,
    icon_url TEXT,
    image_url TEXT,
    product_count INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_accessory BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Fields:**
- `parent_id`: Creates category hierarchy (e.g., "Grinders" → "Manual Grinders")
- `level`: Depth in hierarchy (0 = root, 1 = subcategory, etc.)
- `is_accessory`: Marks accessory categories (scales, kettles, etc.)

### 3. `products` (★ Core Table)
**Unified product table** with integrated specifications in JSONB format.

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    
    -- Relations
    category_id UUID NOT NULL REFERENCES product_categories(id),
    brand_id UUID NOT NULL REFERENCES brands(id),
    
    -- Basic Info (Multi-language)
    name JSONB NOT NULL CHECK (name ? 'en' AND name ? 'ko'),
    description JSONB,
    model_number TEXT,
    identifiers JSONB,  -- e.g., {"sku": "ABC123", "upc": "123456"}
    
    -- Images
    image_url TEXT,
    images TEXT[],
    
    -- Manufacturing
    manufacturer_country VARCHAR(2),
    release_date DATE,
    discontinued_date DATE,
    
    -- Wiki Metadata
    view_count INTEGER DEFAULT 0,
    edit_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    
    -- i18n Settings
    available_locales TEXT[] DEFAULT ARRAY['ko', 'en'],
    default_locale TEXT DEFAULT 'en',
    
    -- Physical Specifications (Common Fields)
    dimensions JSONB,  -- {"width_mm": 100, "height_mm": 200, "depth_mm": 150}
    weight JSONB,      -- {"value": 5.2, "unit": "kg"}
    power_watts INTEGER,
    voltage TEXT,
    
    -- 🌟 UNIFIED PRODUCT SPECIFICATIONS (JSONB)
    specs JSONB DEFAULT '{}',
    
    -- Pricing Information
    current_price_min NUMERIC(10,2),
    current_price_max NUMERIC(10,2),
    current_price_currency VARCHAR(3) DEFAULT 'USD',
    current_price_updated_at TIMESTAMPTZ,
    
    -- Purchase Links
    purchase_links JSONB DEFAULT '[]',  -- Array of {marketplace, region, url, affiliate_id}
    official_url TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4. `product_pricing`
Historical price tracking for market analysis.

```sql
CREATE TABLE product_pricing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    currency VARCHAR(3) DEFAULT 'USD',
    min_price NUMERIC(10,2),
    max_price NUMERIC(10,2),
    msrp NUMERIC(10,2),
    market VARCHAR(50),  -- e.g., "US", "KR", "EU"
    marketplace TEXT,    -- e.g., "amazon", "coupang"
    price_type VARCHAR(50),  -- "retail", "wholesale", "used"
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_until DATE,
    source TEXT,
    notes TEXT,
    is_current BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## JSONB Specs Structure

The `products.specs` field contains category-specific specifications as a flexible JSONB object. Below are the standardized spec structures for each category.

### Espresso Machines (`category: espresso-machines`)

```json
{
  "machine_type": "Semi-Automatic",
  "boiler_type": "Dual Boiler",
  "boiler_material": "Stainless Steel",
  "boiler_capacity_ml": 1400,
  "pump_type": "Rotary",
  "pump_pressure_bar": 9,
  "brew_temperature_celsius": 93,
  "temperature_control_type": "PID",
  "brew_temp_range_celsius": {"min": 88, "max": 96},
  "group_heads": 1,
  "portafilter_size_mm": 58,
  "pre_infusion": true,
  "pre_infusion_type": "Progressive",
  "pre_infusion_duration_seconds": 5,
  "pressure_profiling": true,
  "steam_wand": true,
  "steam_wand_type": "Commercial",
  "hot_water_dispenser": true,
  "water_tank_capacity_l": 2.5,
  "water_source": ["Tank", "Direct Plumb"],
  "built_in_grinder": false,
  "programmable_shots": true,
  "dual_boiler": true,
  "cup_warmer": true,
  "display_type": "LCD",
  "connectivity": ["Wi-Fi", "Bluetooth"]
}
```

### Coffee Grinders (`category: coffee-grinders`)

```json
{
  "grinder_type": "Electric" | "Manual",
  "burr_type": "Flat" | "Conical",
  "burr_material": "Steel" | "Ceramic",
  "burr_size_mm": 64,
  "grind_settings": 120,
  "stepless_adjustment": true,
  "bean_hopper_capacity_g": 250,
  "ground_coffee_capacity_g": 100,
  "motor_power_watts": 350,
  "motor_speed_rpm": 1350,
  "noise_level_db": 68,
  "single_dose": true,
  "grind_retention_g": 0.5,
  "anti_static": true,
  "portafilter_holder": true,
  "grind_consistency_rating": "Excellent",
  "body_material": "Aluminum Alloy",
  "handle_type": "Foldable",  // for manual grinders
  "travel_friendly": true     // for manual grinders
}
```

### Drip Coffee Makers (`category: drip-coffee-makers`)

```json
{
  "brew_method": "Drip",
  "carafe_type": "Thermal",
  "carafe_material": "Stainless Steel",
  "carafe_capacity_cups": 10,
  "carafe_capacity_ml": 1400,
  "brew_temperature_celsius": 92,
  "sca_certified": true,
  "pre_infusion": true,
  "temperature_control": true,
  "temp_range_celsius": {"min": 85, "max": 96},
  "programmable": true,
  "brew_strength_control": true,
  "brew_modes": ["Regular", "Bold", "Iced"],
  "auto_shutoff": true,
  "filter_type": "Paper",
  "water_filter_included": true,
  "permanent_filter_included": false
}
```

### Moka Pots (`category: moka-pots`)

```json
{
  "capacity_ml": 300,
  "capacity_cups": 6,
  "body_material": "Aluminum",
  "chamber_material": "Aluminum",
  "handle_material": "Bakelite",
  "handle_heat_resistant": true,
  "heat_sources": ["Gas", "Electric", "Induction"],
  "induction_compatible": true,
  "safety_valve": true,
  "crema_valve": false,
  "electric": false,
  "dishwasher_safe": false,
  "made_in_country": "IT"
}
```

### Coffee Accessories (`category: coffee-accessories`)

Accessories include scales, kettles, drippers, tampers, pitchers, etc.

```json
{
  "accessory_type": "Scale" | "Kettle" | "Dripper" | "Tamper" | "Pitcher",
  
  // Scale-specific
  "scale_max_weight_g": 3000,
  "scale_accuracy_g": 0.1,
  "scale_precision_g": 0.1,
  "scale_timer": true,
  "scale_auto_timer": true,
  "scale_bluetooth": true,
  "scale_rechargeable": true,
  "scale_water_resistant": true,
  
  // Kettle-specific
  "kettle_type": "Electric",
  "kettle_gooseneck": true,
  "kettle_temp_control": true,
  "kettle_temp_range_celsius": {"min": 40, "max": 100},
  "kettle_hold_function": true,
  "capacity_ml": 800,
  
  // Dripper-specific
  "dripper_type": "V60",
  "dripper_size": "02",
  "material": "Ceramic",
  "rib_design": "Spiral",
  "hole_count": 1,
  
  // Tamper-specific
  "tamper_diameter_mm": 58,
  "tamper_base_type": "Flat",
  "tamper_calibrated": true,
  "tamper_calibration_pressure_lbs": 30
}
```

## Querying JSONB Specs

### Basic Queries

```sql
-- Find all electric grinders
SELECT * FROM products 
WHERE specs->>'grinder_type' = 'Electric';

-- Find grinders with burr size >= 64mm
SELECT * FROM products 
WHERE (specs->>'burr_size_mm')::int >= 64;

-- Find espresso machines with PID
SELECT * FROM products 
WHERE specs->>'temperature_control_type' = 'PID';

-- Boolean filters
SELECT * FROM products 
WHERE (specs->>'dual_boiler')::boolean = true;
```

### Advanced Queries

```sql
-- Find products within price range with specific specs
SELECT * FROM products 
WHERE category_id = (SELECT id FROM product_categories WHERE slug = 'coffee-grinders')
  AND current_price_min >= 100
  AND current_price_max <= 500
  AND specs->>'burr_type' = 'Flat'
  AND (specs->>'single_dose')::boolean = true;

-- Search with multiple spec filters
SELECT * FROM products
WHERE specs->>'grinder_type' = 'Manual'
  AND (specs->>'burr_size_mm')::int >= 40
  AND (specs->>'stepless_adjustment')::boolean = true
  AND (specs->>'travel_friendly')::boolean = true;
```

### Indexing for Performance

```sql
-- Create GIN index on specs JSONB field
CREATE INDEX idx_products_specs ON products USING GIN (specs);

-- Create specific indexes for common queries
CREATE INDEX idx_products_grinder_type ON products ((specs->>'grinder_type'));
CREATE INDEX idx_products_burr_type ON products ((specs->>'burr_type'));
CREATE INDEX idx_products_machine_type ON products ((specs->>'machine_type'));
```

## Benefits of Unified Specs

### ✅ Advantages

1. **Schema Flexibility**: Add new product categories without ALTER TABLE
2. **Simplified Queries**: No complex JOINs across multiple spec tables
3. **Single Source of Truth**: All specs in one place
4. **Easy Updates**: Update specs without migrating data between tables
5. **Better Performance**: GIN indexes on JSONB are highly efficient
6. **API Simplicity**: Return complete product data in single query

### ⚠️ Considerations

1. **Type Safety**: No database-level type constraints (handled at application level)
2. **Schema Documentation**: Need to maintain clear documentation of expected fields
3. **Validation**: Application must validate spec structure
4. **Migration**: Existing data needs to be migrated from separate tables

## Migration Notes

The database was migrated from separate spec tables to unified specs:

```sql
-- Old structure (DEPRECATED)
- espresso_machine_specs
- coffee_grinder_specs  
- drip_coffee_maker_specs
- moka_pot_specs
- coffee_accessory_specs

-- New structure (CURRENT)
- products.specs (JSONB field containing all specs)
```

Migration was completed on 2025-11-11 with zero data loss.

## Database Statistics

- **Total Brands**: 70
- **Total Categories**: 34
- **Total Products**: 62 (55 migrated + 7 new grinders)
- **Average Specs per Product**: ~20-50 fields depending on category

## Related Files

- **API Handler**: `src/handlers/product_handler.rs`
- **Models**: `src/models/product.rs`
- **Migrations**: `supabase/migrations/`
