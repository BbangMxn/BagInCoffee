import { apiClient, type ApiResponse } from './client';
import type {
	MarketplaceItem,
	MarketplaceItemWithSeller,
	CreateMarketplaceItemInput
} from '$lib/types/marketplace';

/**
 * 🛒 Marketplace API
 */

export const marketplaceApi = {
	/**
	 * 중고거래 아이템 목록 조회
	 */
	async getAll(params?: {
		page?: number;
		page_size?: number;
		status?: 'active' | 'reserved' | 'sold';
		condition?: string;
		min_price?: number;
		max_price?: number;
		search?: string;
	}): Promise<ApiResponse<MarketplaceItemWithSeller[]>> {
		return apiClient.get<MarketplaceItemWithSeller[]>('/marketplace', params);
	},

	/**
	 * 특정 아이템 조회
	 */
	async getById(id: string): Promise<ApiResponse<MarketplaceItemWithSeller>> {
		return apiClient.get<MarketplaceItemWithSeller>(`/marketplace/${id}`);
	},

	/**
	 * 아이템 등록
	 */
	async create(input: CreateMarketplaceItemInput): Promise<ApiResponse<MarketplaceItem>> {
		return apiClient.post<MarketplaceItem>('/marketplace', input);
	},

	/**
	 * 아이템 수정
	 */
	async update(
		id: string,
		updates: Partial<CreateMarketplaceItemInput>
	): Promise<ApiResponse<MarketplaceItem>> {
		return apiClient.patch<MarketplaceItem>(`/marketplace/${id}`, updates);
	},

	/**
	 * 아이템 삭제
	 */
	async delete(id: string): Promise<ApiResponse<{ message: string }>> {
		return apiClient.delete(`/marketplace/${id}`);
	},

	/**
	 * 판매중인 아이템만 조회
	 */
	async getActive(params?: { page?: number; page_size?: number }): Promise<
		ApiResponse<MarketplaceItemWithSeller[]>
	> {
		return apiClient.get<MarketplaceItemWithSeller[]>('/marketplace', {
			...params,
			status: 'active'
		});
	}
};
