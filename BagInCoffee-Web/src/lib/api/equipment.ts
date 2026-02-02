import { apiClient, type ApiResponse } from './client';
import type {
	Equipment,
	EquipmentWithRelations,
	EquipmentCategory,
	CreateEquipmentInput,
	UpdateEquipmentInput,
	EquipmentReviewWithAuthor
} from '$lib/types/equipment';

/**
 * 🔧 Equipment API
 * 장비 관련 API 요청 처리
 */

export const equipmentApi = {
	/**
	 * 모든 카테고리 조회
	 */
	async getCategories(): Promise<ApiResponse<EquipmentCategory[]>> {
		return apiClient.get<EquipmentCategory[]>('/equipment/categories');
	},

	/**
	 * 특정 카테고리 조회
	 */
	async getCategoryById(categoryId: string): Promise<ApiResponse<EquipmentCategory>> {
		return apiClient.get<EquipmentCategory>(`/equipment/categories/${categoryId}`);
	},

	/**
	 * 장비 목록 조회 (브랜드 정보 포함)
	 * @param params - 필터 옵션
	 * @param params.page - 페이지 번호 (기본값: 1)
	 * @param params.page_size - 페이지 크기 (기본값: 20)
	 * @param params.category_id - 카테고리 ID 필터
	 * @param params.brand_id - 브랜드 ID 필터 (신규)
	 * @param params.brand - 브랜드명 검색 (레거시)
	 * @param params.min_rating - 최소 평점 필터
	 * @param params.sort_by - 정렬 기준
	 */
	async getAll(params?: {
		page?: number;
		page_size?: number;
		category_id?: string;
		brand_id?: string;
		brand?: string;
		min_rating?: number;
		sort_by?: 'newest' | 'oldest' | 'price_low' | 'price_high' | 'rating' | 'popular';
	}): Promise<ApiResponse<EquipmentWithRelations[]>> {
		return apiClient.get<EquipmentWithRelations[]>('/equipment', params);
	},

	/**
	 * 특정 장비 상세 조회 (브랜드 및 카테고리 정보 포함)
	 * @param id - 장비 ID
	 */
	async getById(id: string): Promise<ApiResponse<EquipmentWithRelations>> {
		return apiClient.get<EquipmentWithRelations>(`/equipment/${id}`);
	},

	/**
	 * 장비 생성 (관리자만)
	 * @param input - 장비 생성 데이터
	 */
	async create(input: CreateEquipmentInput): Promise<ApiResponse<Equipment>> {
		return apiClient.post<Equipment>('/equipment', input);
	},

	/**
	 * 장비 수정 (관리자만)
	 * @param id - 장비 ID
	 * @param updates - 수정할 데이터
	 */
	async update(id: string, updates: UpdateEquipmentInput): Promise<ApiResponse<Equipment>> {
		return apiClient.patch<Equipment>(`/equipment/${id}`, updates);
	},

	/**
	 * 장비 삭제 (관리자만)
	 * @param id - 장비 ID
	 */
	async delete(id: string): Promise<ApiResponse<{ message: string }>> {
		return apiClient.delete(`/equipment/${id}`);
	},

	/**
	 * 리뷰 목록 조회
	 */
	async getReviews(
		equipmentId: string,
		params?: { page?: number; page_size?: number }
	): Promise<ApiResponse<EquipmentReviewWithAuthor[]>> {
		return apiClient.get<EquipmentReviewWithAuthor[]>(
			`/equipment/${equipmentId}/reviews`,
			params
		);
	},

	/**
	 * 리뷰 작성
	 */
	async createReview(
		equipmentId: string,
		review: { rating: number; review: string }
	): Promise<ApiResponse<any>> {
		return apiClient.post(`/equipment/${equipmentId}/reviews`, review);
	}
};
