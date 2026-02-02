/**
 * API 응답 타입 정의
 * 모든 API 엔드포인트의 표준 응답 형식
 */

import type {
	Equipment,
	EquipmentWithRelations,
	EquipmentDetail,
	EquipmentReview,
	EquipmentReviewWithAuthor,
	Brand,
	BrandWithCategories,
	EquipmentCategory
} from './equipment';

// ==================================================================================
// Generic API Response
// ==================================================================================

/**
 * 표준 API 응답 형식
 */
export interface ApiResponse<T = any> {
	/** 성공 여부 */
	success: boolean;

	/** 응답 데이터 */
	data?: T;

	/** 페이지네이션 정보 */
	pagination?: PaginationInfo;

	/** 에러 정보 */
	error?: ApiError;
}

/**
 * 페이지네이션 정보
 */
export interface PaginationInfo {
	/** 현재 페이지 */
	page: number;

	/** 페이지당 아이템 수 */
	page_size: number;

	/** 전체 아이템 수 */
	total_count: number;

	/** 전체 페이지 수 */
	total_pages: number;

	/** 다음 페이지 존재 여부 */
	has_next: boolean;

	/** 이전 페이지 존재 여부 */
	has_previous: boolean;
}

/**
 * API 에러 정보
 */
export interface ApiError {
	/** 에러 코드 */
	code: string;

	/** 에러 메시지 */
	message: string;

	/** 상세 정보 (선택적) */
	details?: any;
}

// ==================================================================================
// Equipment API Responses
// ==================================================================================

/**
 * 장비 목록 조회 응답
 */
export type GetEquipmentListResponse = ApiResponse<EquipmentWithRelations[]>;

/**
 * 장비 상세 조회 응답
 */
export type GetEquipmentDetailResponse = ApiResponse<EquipmentDetail>;

/**
 * 장비 생성 응답
 */
export type CreateEquipmentResponse = ApiResponse<Equipment>;

/**
 * 장비 수정 응답
 */
export type UpdateEquipmentResponse = ApiResponse<Equipment>;

/**
 * 장비 삭제 응답
 */
export type DeleteEquipmentResponse = ApiResponse<{ id: string }>;

// ==================================================================================
// Brand API Responses
// ==================================================================================

/**
 * 브랜드 목록 조회 응답
 */
export type GetBrandListResponse = ApiResponse<Brand[]>;

/**
 * 브랜드 상세 조회 응답 (카테고리 포함)
 */
export type GetBrandDetailResponse = ApiResponse<BrandWithCategories>;

/**
 * 브랜드 생성 응답
 */
export type CreateBrandResponse = ApiResponse<Brand>;

/**
 * 브랜드 수정 응답
 */
export type UpdateBrandResponse = ApiResponse<Brand>;

// ==================================================================================
// Category API Responses
// ==================================================================================

/**
 * 카테고리 목록 조회 응답
 */
export type GetCategoryListResponse = ApiResponse<EquipmentCategory[]>;

/**
 * 카테고리별 브랜드 조회 응답
 */
export type GetBrandsByCategoryResponse = ApiResponse<Brand[]>;

// ==================================================================================
// Review API Responses
// ==================================================================================

/**
 * 리뷰 목록 조회 응답
 */
export type GetReviewListResponse = ApiResponse<EquipmentReviewWithAuthor[]>;

/**
 * 리뷰 생성 응답
 */
export type CreateReviewResponse = ApiResponse<EquipmentReview>;

/**
 * 리뷰 수정 응답
 */
export type UpdateReviewResponse = ApiResponse<EquipmentReview>;

/**
 * 리뷰 삭제 응답
 */
export type DeleteReviewResponse = ApiResponse<{ id: string }>;
