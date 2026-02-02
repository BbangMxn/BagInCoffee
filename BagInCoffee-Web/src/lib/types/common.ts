/**
 * 공통 타입 정의
 */

// ==================================================================================
// API 응답 구조
// ==================================================================================

/**
 * 성공 응답
 */
export interface ApiSuccessResponse<T> {
	success: true;
	data: T;
}

/**
 * 에러 응답
 */
export interface ApiErrorResponse {
	success: false;
	error: {
		message: string;
		code?: string;
	};
}

/**
 * 통합 API 응답 타입
 */
export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;

// ==================================================================================
// 페이지네이션
// ==================================================================================

/**
 * 페이지네이션 정보
 */
export interface PaginationInfo {
	/** 현재 페이지 */
	page: number;

	/** 페이지당 아이템 수 */
	per_page: number;

	/** 전체 아이템 수 */
	total_count: number;

	/** 전체 페이지 수 */
	total_pages: number;
}

// ==================================================================================
// 이미지 관련
// ==================================================================================

/**
 * 이미지 정보
 */
export interface ImageInfo {
	/** 이미지 URL */
	url: string;

	/** 너비 (px) */
	width?: number;

	/** 높이 (px) */
	height?: number;

	/** 대체 텍스트 */
	alt?: string;
}

// ==================================================================================
// 공통 엔티티 베이스
// ==================================================================================

/**
 * 타임스탬프 기본 인터페이스
 */
export interface Timestamped {
	/** 생성 일시 */
	created_at: string;

	/** 수정 일시 */
	updated_at: string;
}

/**
 * ID를 가진 엔티티 기본 인터페이스
 */
export interface Entity extends Timestamped {
	/** 고유 ID */
	id: string;
}

/**
 * 좋아요 및 댓글 카운트를 가진 컨텐츠 인터페이스
 */
export interface Engageable {
	/** 좋아요 개수 */
	likes_count: number;

	/** 댓글 개수 */
	comments_count: number;
}

/**
 * 조회수를 가진 컨텐츠 인터페이스
 */
export interface Viewable {
	/** 조회수 */
	views_count: number;
}

/**
 * 사용자가 작성한 컨텐츠 인터페이스
 */
export interface UserGenerated {
	/** 작성자 ID */
	user_id: string;
}
