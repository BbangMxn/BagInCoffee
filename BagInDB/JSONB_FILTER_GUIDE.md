# JSONB Dynamic Filter Guide

프론트엔드에서 유연하게 사용할 수 있는 동적 JSONB 필터 시스템입니다.

## 🎯 개요

제품의 `specs` JSONB 필드에 저장된 **모든 필드**를 자유롭게 필터링할 수 있습니다.
더 이상 백엔드 코드 수정 없이 프론트엔드에서 원하는 스펙으로 필터링 가능합니다!

## 📋 필터 규칙

### 1. **기본 형식**
모든 스펙 필터는 `spec_` 접두사를 사용합니다:
```
?spec_{field_name}={value}
```

### 2. **필터 타입**

#### ✅ **등호 필터 (Equality)**
특정 값과 정확히 일치하는 항목 조회
```bash
?spec_machine_type=semi-automatic
?spec_burr_type=flat
?spec_grinder_type=electric
?spec_accessory_type=scale
```

**자동 타입 감지:**
- `true`/`false` → Boolean
- 숫자 → Integer 또는 Float
- 그 외 → String

#### ✅ **범위 필터 (Range)**
최소/최대값 범위로 조회
```bash
# 버 크기 54mm ~ 64mm
?spec_burr_size_mm_min=54&spec_burr_size_mm_max=64

# 그룹헤드 1개 이상
?spec_group_heads_min=1

# 용량 6컵 이하
?spec_capacity_cups_max=6

# 무게 500g ~ 1000g
?spec_weight_g_min=500&spec_weight_g_max=1000
```

#### ✅ **배열 포함 필터 (Array Contains)**
배열 필드에 특정 값이 포함되어 있는지 확인
```bash
# heat_sources에 "induction" 포함
?spec_heat_sources_contains=induction

# brew_modes에 "pour-over" 포함  
?spec_brew_modes_contains=pour-over
```

## 🚀 실전 사용 예시

### 1️⃣ **에스프레소 머신 조회**

#### 듀얼 보일러 + PID 제어 + 프리인퓨전
```bash
GET /api/products?category_id={espresso-machine-uuid}
    &spec_dual_boiler=true
    &spec_temperature_stability=PID
    &spec_pre_infusion=true
```

#### 세미오토 + 그룹헤드 1개 + 가격 범위
```bash
GET /api/products?category_id={espresso-machine-uuid}
    &spec_machine_type=semi-automatic
    &spec_group_heads=1
    &price_min=1000000
    &price_max=3000000
    &currency=KRW
```

### 2️⃣ **커피 그라인더 조회**

#### 플랫 버 64mm + 무단 조절 + 정전기 방지
```bash
GET /api/products?category_id={grinder-uuid}
    &spec_burr_type=flat
    &spec_burr_size_mm=64
    &spec_stepless_adjustment=true
    &spec_anti_static=true
```

#### 전동 그라인더 + 버 크기 범위 + 브랜드 필터
```bash
GET /api/products?brand_id={niche-uuid}
    &spec_grinder_type=electric
    &spec_burr_size_mm_min=54
    &spec_burr_size_mm_max=78
```

### 3️⃣ **드립 커피 메이커 조회**

#### SCA 인증 + 보온 유리 + 프로그래밍 가능
```bash
GET /api/products?category_id={drip-maker-uuid}
    &spec_sca_certified=true
    &spec_carafe_type=thermal
    &spec_programmable=true
```

### 4️⃣ **모카포트 조회**

#### 인덕션 호환 + 스테인리스 + 6컵
```bash
GET /api/products?category_id={moka-pot-uuid}
    &spec_induction_compatible=true
    &spec_body_material=stainless-steel
    &spec_capacity_cups=6
```

### 5️⃣ **커피 액세서리 조회**

#### 스케일 + 블루투스 + 방수
```bash
GET /api/products?category_id={accessory-uuid}
    &spec_accessory_type=scale
    &spec_scale_bluetooth=true
    &spec_scale_water_resistant=true
```

#### 드리퍼 + 세라믹 + 식기세척기 사용 가능
```bash
GET /api/products?category_id={accessory-uuid}
    &spec_accessory_type=dripper
    &spec_material=ceramic-porcelain
    &spec_dishwasher_safe=true
```

### 6️⃣ **복합 조회 (카테고리 + 브랜드 + 스펙 + 정렬)**

```bash
GET /api/products
    ?category_id={grinder-uuid}
    &brand_id={fellow-uuid}
    &spec_burr_type=conical
    &spec_burr_size_mm_min=40
    &price_max=500000
    &sort_by=price
    &order=asc
    &page=0
    &limit=20
```

## 📊 정렬 옵션

```bash
# 가격 오름차순
?sort_by=price&order=asc

# 최신순
?sort_by=created_at&order=desc

# 인기순
?sort_by=view_count&order=desc

# 이름순
?sort_by=name&order=asc

# 출시일순
?sort_by=release_date&order=desc
```

**사용 가능한 sort_by:**
- `name` - 제품명
- `price` - 가격 (current_price_min)
- `created_at` - 생성일
- `updated_at` - 수정일
- `release_date` - 출시일
- `view_count` - 조회수

## 🎨 프론트엔드 구현 예시

### React + TypeScript

```typescript
interface ProductFilters {
  category_id?: string;
  brand_id?: string;
  search?: string;
  price_min?: number;
  price_max?: number;
  sort_by?: 'name' | 'price' | 'created_at' | 'view_count';
  order?: 'asc' | 'desc';
  page?: number;
  limit?: number;
  // 동적 스펙 필터
  [key: `spec_${string}`]: string | boolean | number;
}

// 사용 예시
const filters: ProductFilters = {
  category_id: 'uuid-here',
  spec_burr_type: 'flat',
  spec_burr_size_mm_min: 54,
  spec_burr_size_mm_max: 64,
  spec_anti_static: true,
  sort_by: 'price',
  order: 'asc',
  page: 0,
  limit: 20
};

// URL 쿼리 스트링 생성
const queryString = new URLSearchParams(
  Object.entries(filters)
    .filter(([_, v]) => v !== undefined)
    .map(([k, v]) => [k, String(v)])
).toString();

// API 호출
const response = await fetch(`/api/products?${queryString}`);
```

### Vue 3 Composition API

```vue
<script setup lang="ts">
import { ref, computed } from 'vue';

const filters = ref({
  spec_machine_type: 'semi-automatic',
  spec_dual_boiler: true,
  spec_group_heads_min: 1,
  price_max: 5000000,
  sort_by: 'price',
  order: 'asc'
});

const queryString = computed(() => {
  return new URLSearchParams(
    Object.entries(filters.value)
      .filter(([_, v]) => v !== null && v !== undefined)
      .map(([k, v]) => [k, String(v)])
  ).toString();
});

const products = ref([]);

async function fetchProducts() {
  const res = await fetch(`/api/products?${queryString.value}`);
  products.value = await res.json();
}
</script>
```

## 🔍 실제 DB 쿼리 예시

프론트엔드 요청:
```
GET /api/products?spec_burr_type=flat&spec_burr_size_mm_min=54
```

생성되는 SQL:
```sql
SELECT * FROM products 
WHERE 1=1 
  AND specs->>'burr_type' = 'flat'
  AND (specs->>'burr_size_mm')::int >= 54
ORDER BY created_at DESC 
LIMIT 20 OFFSET 0
```

## 📌 주의사항

1. **필드명은 정확히**: specs JSONB에 실제 존재하는 필드명을 사용하세요
2. **타입 자동 감지**: 값의 형태에 따라 타입이 자동 감지됩니다
3. **범위 필터**: `_min`, `_max` 접미사 사용
4. **배열 필터**: `_contains` 접미사 사용
5. **캐싱**: 동일한 필터 조합은 캐시에서 제공됩니다 (5분 TTL)

## 🎯 장점

✅ **무한 확장성**: 새로운 스펙 필드 추가 시 백엔드 코드 수정 불필요  
✅ **타입 안전성**: PostgreSQL 타입 캐스팅으로 안전한 쿼리  
✅ **성능**: 인덱스 활용 + Redis 캐싱  
✅ **유연성**: 프론트엔드에서 자유롭게 필터 조합  
✅ **유지보수성**: 단일 쿼리 빌더로 모든 필터 처리  

## 📖 DB_STRUCTURE.md 참고

각 카테고리별 사용 가능한 스펙 필드는 `DB_STRUCTURE.md` 문서를 참고하세요.
