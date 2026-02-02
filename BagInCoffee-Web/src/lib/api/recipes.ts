import { apiClient, type ApiResponse } from './client';
import type { Recipe, RecipeWithAuthor, CreateRecipeInput } from '$lib/types/recipe';

/**
 * ☕ Recipes API
 */

export const recipesApi = {
	/**
	 * 레시피 목록 조회
	 */
	async getAll(params?: {
		page?: number;
		page_size?: number;
		brew_method?: string;
		difficulty?: 'easy' | 'medium' | 'hard';
		popular?: boolean;
		search?: string;
	}): Promise<ApiResponse<RecipeWithAuthor[]>> {
		return apiClient.get<RecipeWithAuthor[]>('/recipes', params);
	},

	/**
	 * 특정 레시피 조회
	 */
	async getById(id: string): Promise<ApiResponse<RecipeWithAuthor>> {
		return apiClient.get<RecipeWithAuthor>(`/recipes/${id}`);
	},

	/**
	 * 레시피 작성
	 */
	async create(input: CreateRecipeInput): Promise<ApiResponse<Recipe>> {
		return apiClient.post<Recipe>('/recipes', input);
	},

	/**
	 * 레시피 수정
	 */
	async update(id: string, updates: Partial<CreateRecipeInput>): Promise<ApiResponse<Recipe>> {
		return apiClient.patch<Recipe>(`/recipes/${id}`, updates);
	},

	/**
	 * 레시피 삭제
	 */
	async delete(id: string): Promise<ApiResponse<{ message: string }>> {
		return apiClient.delete(`/recipes/${id}`);
	},

	/**
	 * 인기 레시피 조회
	 */
	async getPopular(params?: { page?: number; page_size?: number }): Promise<
		ApiResponse<RecipeWithAuthor[]>
	> {
		return apiClient.get<RecipeWithAuthor[]>('/recipes', { ...params, popular: true });
	}
};
