import { apiClient, type ApiResponse } from './client';
import type { CoffeeGuide, GuideCategory } from '$lib/types/content';

/**
 * 📚 Guide API
 */
export const guideApi = {
	/**
	 * 가이드 목록 조회
	 */
	async getAll(params?: {
		page?: number;
		page_size?: number;
		category?: GuideCategory;
		difficulty?: 'beginner' | 'intermediate' | 'advanced' | 'master';
	}): Promise<ApiResponse<CoffeeGuide[]>> {
		return apiClient.get<CoffeeGuide[]>('/guide', params);
	},

	/**
	 * 특정 가이드 조회 (마크다운 콘텐츠 포함)
	 */
	async getById(id: string): Promise<ApiResponse<CoffeeGuide>> {
		return apiClient.get<CoffeeGuide>(`/guide/${id}`);
	},

	/**
	 * 가이드 생성
	 */
	async create(input: {
		title: string;
		content: string;
		category: GuideCategory;
		difficulty: 'beginner' | 'intermediate' | 'advanced' | 'master';
		estimated_time: number;
		thumbnail_url?: string;
	}): Promise<ApiResponse<CoffeeGuide>> {
		return apiClient.post<CoffeeGuide>('/guide', input);
	},

	/**
	 * 가이드 수정
	 */
	async update(
		id: string,
		updates: Partial<{
			title: string;
			content: string;
			category: GuideCategory;
			difficulty: 'beginner' | 'intermediate' | 'advanced' | 'master';
			estimated_time: number;
			thumbnail_url?: string;
		}>
	): Promise<ApiResponse<CoffeeGuide>> {
		return apiClient.patch<CoffeeGuide>(`/guide/${id}`, updates);
	},

	/**
	 * 가이드 삭제
	 */
	async delete(id: string): Promise<ApiResponse<{ message: string }>> {
		return apiClient.delete(`/guide/${id}`);
	}
};
