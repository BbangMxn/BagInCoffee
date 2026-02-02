import type { UserProfileSimple } from './user';
import type { Entity } from './common';

// ==================================================================================
// 1. Brand - 브랜드 마스터 테이블
// ==================================================================================

/**
 * 커피 장비 브랜드 정보
 * @table brands
 * @rls Enabled (조회: 모든 사용자, 수정: 관리자만)
 */
export interface Brand extends Entity {
	/** 브랜드 한글명 (필수, 고유값) */
	name: string;

	/** 브랜드 영문명 */
	name_en: string | null;

	/** 브랜드 설명 */
	description: string | null;

	/** 로고 이미지 URL */
	logo_url: string | null;

	/** 공식 웹사이트 */
	website: string | null;

	/** 본사 국가 */
	country: string | null;

	/** 설립 연도 */
	founded_year: number | null;
}

// ==================================================================================
// 2. EquipmentCategory - 장비 카테고리
// ==================================================================================

/**
 * 커피 장비 카테고리 (대분류)
 * @table equipment_categories
 * @rls Enabled (조회: 모든 사용자)
 */
export interface EquipmentCategory {
	/** 카테고리 고유 ID */
	id: string;

	/** 카테고리명 (필수, 고유값) */
	name: string;

	/** 카테고리 설명 */
	description: string | null;

	/** lucide 아이콘명 */
	icon: string | null;

	/** 생성 일시 */
	created_at: string;
}

// ==================================================================================
// 3. BrandCategory - 브랜드-카테고리 관계 (M:N)
// ==================================================================================

/**
 * 브랜드와 카테고리의 다대다 관계
 * @table brand_categories
 * @rls Enabled (조회: 모든 사용자, 수정: 관리자만)
 * @constraint UNIQUE(brand_id, category_id)
 */
export interface BrandCategory {
	/** 관계 고유 ID */
	id: string;

	/** 브랜드 참조 (FK → brands.id) */
	brand_id: string;

	/** 카테고리 참조 (FK → equipment_categories.id) */
	category_id: string;

	/** 생성 일시 */
	created_at: string;
}

// ==================================================================================
// 4. Equipment - 장비 정보
// ==================================================================================

/**
 * 커피 장비 제품 정보
 * @table equipment
 * @rls Enabled (조회: 모든 사용자)
 */
export interface Equipment extends Entity {
	/** 카테고리 참조 (FK → equipment_categories.id) */
	category_id: string | null;

	/** 브랜드 참조 (FK → brands.id) - 신규 컬럼 */
	brand_id: string | null;

	/** 브랜드명 (레거시 컬럼, 마이그레이션 대기 중) */
	brand: string;

	/** 모델명 (필수) */
	model: string;

	/** 제품 설명 */
	description: string | null;

	/** 제품 이미지 URL */
	image_url: string | null;

	/** 제품 스펙 (JSON) */
	specs: EquipmentSpecs | null;

	/** 가격대 */
	price_range: string | null;

	/** 평균 평점 */
	rating: number | null;

	/** 리뷰 개수 */
	reviews_count: number;

	/** 구매 링크 (JSON) */
	purchase_links: PurchaseLinks | null;

	// 로컬 데이터용 선택적 필드
	name?: string;
	category?: string;
	features?: string[];
	pros?: string[];
	cons?: string[];
	price?: number;
	releaseDate?: string;
}

// ==================================================================================
// 5. EquipmentReview - 장비 리뷰
// ==================================================================================

/**
 * 장비 리뷰
 * @table equipment_reviews
 * @rls Enabled (조회: 모든 사용자, 작성/수정: 본인만)
 */
export interface EquipmentReview extends Entity {
	/** 작성자 ID (FK → auth.users.id) */
	user_id: string;

	/** 장비 ID (FK → equipment.id) */
	equipment_id: string;

	/** 평점 (1-5점) */
	rating: number | null;

	/** 리뷰 내용 */
	review: string | null;
}

// ==================================================================================
// Helper Types & DTOs
// ==================================================================================

/**
 * 장비 스펙 (JSONB)
 */
export interface EquipmentSpecs {
	[key: string]: string | number | boolean;
}

/**
 * 구매 링크 (JSONB)
 * 여러 쇼핑몰의 판매 링크를 저장
 */
export interface PurchaseLinks {
	/** 네이버 쇼핑 */
	naver?: string;
	/** 쿠팡 */
	coupang?: string;
	/** 아마존 */
	amazon?: string;
	/** 공식 사이트 */
	official?: string;
	/** 기타 쇼핑몰 */
	[key: string]: string | undefined;
}

/**
 * 브랜드 + 카테고리 정보 (조인)
 */
export interface BrandWithCategories extends Brand {
	/** 브랜드가 속한 카테고리 목록 */
	categories?: EquipmentCategory[];
}

/**
 * 장비 + 브랜드 + 카테고리 정보 (조인)
 */
export interface EquipmentWithRelations extends Equipment {
	/** 브랜드 정보 */
	brand_info?: Brand;

	/** 카테고리 정보 */
	equipment_category?: EquipmentCategory;
}

/**
 * 장비 + 모든 관련 정보 (상세 페이지용)
 */
export interface EquipmentDetail extends EquipmentWithRelations {
	/** 리뷰 목록 */
	reviews?: EquipmentReviewWithAuthor[];
}

/**
 * 리뷰 + 작성자 정보
 */
export interface EquipmentReviewWithAuthor extends EquipmentReview {
	/** 작성자 프로필 */
	author: UserProfileSimple;
}

// ==================================================================================
// Input DTOs
// ==================================================================================

/**
 * 장비 생성 Input
 */
export interface CreateEquipmentInput {
	category_id?: string;
	brand_id?: string;
	brand: string; // 레거시 지원
	model: string;
	description?: string;
	image_url?: string;
	specs?: EquipmentSpecs;
	price_range?: string;
}

/**
 * 장비 수정 Input
 */
export interface UpdateEquipmentInput {
	category_id?: string;
	brand_id?: string;
	model?: string;
	description?: string;
	image_url?: string;
	specs?: EquipmentSpecs;
	price_range?: string;
}

/**
 * 브랜드 생성 Input
 */
export interface CreateBrandInput {
	name: string;
	name_en?: string;
	description?: string;
	logo_url?: string;
	website?: string;
	country?: string;
	founded_year?: number;
}

/**
 * 브랜드 수정 Input
 */
export interface UpdateBrandInput {
	name?: string;
	name_en?: string;
	description?: string;
	logo_url?: string;
	website?: string;
	country?: string;
	founded_year?: number;
}

/**
 * 리뷰 생성 Input
 */
export interface CreateReviewInput {
	equipment_id: string;
	rating: number;
	review?: string;
}

// ==================================================================================
// Legacy Support (기존 코드 호환성)
// ==================================================================================

/**
 * @deprecated Use EquipmentWithRelations instead
 */
export interface EquipmentWithCategory extends EquipmentWithRelations {}