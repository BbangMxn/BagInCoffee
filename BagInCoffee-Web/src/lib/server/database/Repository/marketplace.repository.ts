import type { SupabaseClient } from '@supabase/supabase-js';
import type {
	MarketplaceItem,
	MarketplaceItemWithSeller,
	CreateMarketplaceItemInput
} from '$lib/types/marketplace';
import type { UserProfileSimple } from '$lib/types/user';

/**
 * 🛒 MarketplaceRepository
 *
 * 중고거래 아이템 관리
 * - 아이템 CRUD
 * - 판매자 정보 조인
 * - 상태별 필터링 (active, reserved, sold)
 * - 가격 범위 검색
 */
export class MarketplaceRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 아이템 ID로 조회 (판매자 정보 포함)
	 */
	async findById(itemId: string): Promise<MarketplaceItemWithSeller | null> {
		const { data, error } = await this.supabase
			.from('marketplace_items')
			.select(
				`
				*,
				seller:profiles!seller_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`
			)
			.eq('id', itemId)
			.single();

		if (error || !data) return null;

		return {
			...data,
			seller: data.seller as UserProfileSimple
		} as MarketplaceItemWithSeller;
	}

	/**
	 * 아이템 목록 조회 (페이지네이션, 필터링)
	 */
	async findAll(
		page = 1,
		pageSize = 20,
		filters?: {
			status?: 'active' | 'reserved' | 'sold';
			condition?: string;
			min_price?: number;
			max_price?: number;
			seller_id?: string;
		}
	): Promise<{ items: MarketplaceItemWithSeller[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		let query = this.supabase
			.from('marketplace_items')
			.select(
				`
				*,
				seller:profiles!seller_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.order('created_at', { ascending: false })
			.range(from, to);

		// 필터 적용
		if (filters?.status) {
			query = query.eq('status', filters.status);
		}
		if (filters?.condition) {
			query = query.eq('condition', filters.condition);
		}
		if (filters?.min_price !== undefined) {
			query = query.gte('price', filters.min_price);
		}
		if (filters?.max_price !== undefined) {
			query = query.lte('price', filters.max_price);
		}
		if (filters?.seller_id) {
			query = query.eq('seller_id', filters.seller_id);
		}

		const { data, error, count } = await query;

		if (error || !data) {
			return { items: [], count: 0 };
		}

		const items = data.map((item) => ({
			...item,
			seller: item.seller as UserProfileSimple
		})) as MarketplaceItemWithSeller[];

		return { items, count: count ?? 0 };
	}

	/**
	 * 판매중인 아이템만 조회
	 */
	async findActive(
		page = 1,
		pageSize = 20
	): Promise<{ items: MarketplaceItemWithSeller[]; count: number }> {
		return this.findAll(page, pageSize, { status: 'active' });
	}

	/**
	 * 특정 판매자의 아이템 조회
	 */
	async findBySellerId(
		sellerId: string,
		page = 1,
		pageSize = 20
	): Promise<{ items: MarketplaceItem[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('marketplace_items')
			.select('*', { count: 'exact' })
			.eq('seller_id', sellerId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { items: [], count: 0 };
		}

		return { items: data as MarketplaceItem[], count: count ?? 0 };
	}

	/**
	 * 아이템 검색 (제목, 설명)
	 */
	async search(
		query: string,
		page = 1,
		pageSize = 20
	): Promise<{ items: MarketplaceItemWithSeller[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('marketplace_items')
			.select(
				`
				*,
				seller:profiles!seller_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.or(`title.ilike.%${query}%,description.ilike.%${query}%`)
			.eq('status', 'active') // 판매중인 것만
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { items: [], count: 0 };
		}

		const items = data.map((item) => ({
			...item,
			seller: item.seller as UserProfileSimple
		})) as MarketplaceItemWithSeller[];

		return { items, count: count ?? 0 };
	}

	/**
	 * 아이템 생성
	 */
	async create(sellerId: string, input: CreateMarketplaceItemInput): Promise<MarketplaceItem> {
		const { data, error } = await this.supabase
			.from('marketplace_items')
			.insert({
				seller_id: sellerId,
				title: input.title,
				description: input.description ?? null,
				price: input.price,
				equipment_id: input.equipment_id ?? null,
				condition: input.condition,
				images: input.images ?? null,
				location: input.location ?? null,
				status: 'active'
			})
			.select()
			.single();

		if (error) throw error;
		return data as MarketplaceItem;
	}

	/**
	 * 아이템 수정
	 */
	async update(
		itemId: string,
		sellerId: string,
		updates: Partial<CreateMarketplaceItemInput>
	): Promise<MarketplaceItem> {
		const { data, error } = await this.supabase
			.from('marketplace_items')
			.update({
				...updates,
				updated_at: new Date().toISOString()
			})
			.eq('id', itemId)
			.eq('seller_id', sellerId) // 판매자만 수정 가능
			.select()
			.single();

		if (error) throw error;
		return data as MarketplaceItem;
	}

	/**
	 * 아이템 상태 변경
	 */
	async updateStatus(
		itemId: string,
		sellerId: string,
		status: 'active' | 'reserved' | 'sold'
	): Promise<MarketplaceItem> {
		const { data, error } = await this.supabase
			.from('marketplace_items')
			.update({
				status,
				updated_at: new Date().toISOString()
			})
			.eq('id', itemId)
			.eq('seller_id', sellerId)
			.select()
			.single();

		if (error) throw error;
		return data as MarketplaceItem;
	}

	/**
	 * 아이템 삭제
	 */
	async delete(itemId: string, sellerId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('marketplace_items')
			.delete()
			.eq('id', itemId)
			.eq('seller_id', sellerId); // 판매자만 삭제 가능

		return !error;
	}

	/**
	 * 가격 범위로 필터링
	 */
	async findByPriceRange(
		minPrice: number,
		maxPrice: number,
		page = 1,
		pageSize = 20
	): Promise<{ items: MarketplaceItemWithSeller[]; count: number }> {
		return this.findAll(page, pageSize, { min_price: minPrice, max_price: maxPrice });
	}

	/**
	 * 상태별 통계
	 */
	async getStatsBySeller(sellerId: string): Promise<{
		active: number;
		reserved: number;
		sold: number;
		total: number;
	}> {
		const { data } = await this.supabase
			.from('marketplace_items')
			.select('status')
			.eq('seller_id', sellerId);

		if (!data) return { active: 0, reserved: 0, sold: 0, total: 0 };

		const stats = {
			active: data.filter((item) => item.status === 'active').length,
			reserved: data.filter((item) => item.status === 'reserved').length,
			sold: data.filter((item) => item.status === 'sold').length,
			total: data.length
		};

		return stats;
	}
}
