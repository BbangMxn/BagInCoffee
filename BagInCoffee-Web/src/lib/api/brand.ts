import { apiClient, type ApiResponse } from './client';
import type {
	Brand,
	BrandWithCategories,
	CreateBrandInput,
	UpdateBrandInput
} from '$lib/types/equipment';

/**
 * 🏷️ Brand API
 * 브랜드 관련 API 요청 처리
 */

export const brandApi = {
	/**
	 * 브랜드 목록 조회
	 * @param params - 필터 옵션
	 * @param params.country - 국가 필터 (예: 'KR', 'US')
	 * @param params.search - 검색어 (브랜드명 또는 영문명)
	 * @param params.category_id - 카테고리 ID로 필터링
	 */
	async getAll(params?: {
		country?: string;
		search?: string;
		category_id?: string;
	}): Promise<ApiResponse<Brand[]>> {
		return apiClient.get<Brand[]>('/brands', params);
	},

	/**
	 * 특정 브랜드 상세 조회 (카테고리 포함)
	 * @param id - 브랜드 ID
	 */
	async getById(id: string): Promise<ApiResponse<BrandWithCategories>> {
		return apiClient.get<BrandWithCategories>(`/brands/${id}`);
	},

	/**
	 * 브랜드 생성 (관리자만)
	 * @param input - 브랜드 생성 데이터
	 */
	async create(input: CreateBrandInput): Promise<ApiResponse<Brand>> {
		return apiClient.post<Brand>('/brands', input);
	},

	/**
	 * 브랜드 수정 (관리자만)
	 * @param id - 브랜드 ID
	 * @param updates - 수정할 데이터
	 */
	async update(id: string, updates: UpdateBrandInput): Promise<ApiResponse<Brand>> {
		return apiClient.patch<Brand>(`/brands/${id}`, updates);
	},

	/**
	 * 브랜드 삭제 (관리자만)
	 * @param id - 브랜드 ID
	 */
	async delete(id: string): Promise<ApiResponse<{ message: string }>> {
		return apiClient.delete(`/brands/${id}`);
	},

	/**
	 * 브랜드 통계 조회 (국가별 브랜드 수)
	 */
	async getStats(): Promise<
		ApiResponse<
			{
				country: string | null;
				count: number;
			}[]
		>
	> {
		return apiClient.get('/brands/stats');
	}
};
