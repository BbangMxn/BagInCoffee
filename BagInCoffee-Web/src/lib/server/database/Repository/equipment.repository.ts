import type { SupabaseClient } from '@supabase/supabase-js';
import type {
	Equipment,
	EquipmentWithCategory,
	EquipmentWithRelations,
	EquipmentCategory,
	EquipmentReview,
	EquipmentReviewWithAuthor,
	CreateEquipmentInput,
	Brand
} from '$lib/types/equipment';
import type { UserProfileSimple } from '$lib/types/user';

export class EquipmentRepository {
	constructor(private supabase: SupabaseClient) {}

	// ==================== Equipment CRUD ====================

	/**
	 * 장비 ID로 조회 (브랜드 + 카테고리 정보 포함)
	 */
	async findById(equipmentId: string): Promise<EquipmentWithRelations | null> {
		const { data, error } = await this.supabase
			.from('equipment')
			.select(
				`
				*,
				equipment_category:equipment_categories(
					id,
					name,
					description,
					icon,
					created_at
				),
				brand_info:brands(
					id,
					name,
					name_en,
					description,
					logo_url,
					website,
					country,
					founded_year,
					created_at,
					updated_at
				)
			`
			)
			.eq('id', equipmentId)
			.single();

		if (error || !data) return null;

		return data as EquipmentWithRelations;
	}

	/**
	 * 장비 목록 조회 (페이지네이션, 필터링, 정렬)
	 * 브랜드 + 카테고리 정보 포함
	 */
	async findAll(
		page = 1,
		pageSize = 20,
		filters?: {
			categoryId?: string;
			brandId?: string; // 신규: brand_id로 필터
			brand?: string; // 레거시: 브랜드명 검색
			minPrice?: number;
			maxPrice?: number;
			minRating?: number;
			sortBy?: 'newest' | 'oldest' | 'price_low' | 'price_high' | 'rating' | 'popular';
		}
	): Promise<{ equipment: EquipmentWithRelations[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		let query = this.supabase
			.from('equipment')
			.select(
				`
				*,
				equipment_category:equipment_categories(
					id,
					name,
					description,
					icon,
					created_at
				),
				brand_info:brands(
					id,
					name,
					name_en,
					logo_url,
					country
				)
			`,
				{ count: 'exact' }
			)
			.range(from, to);

		// 필터 적용
		if (filters?.categoryId) {
			query = query.eq('category_id', filters.categoryId);
		}

		// 브랜드 ID로 필터 (신규)
		if (filters?.brandId) {
			query = query.eq('brand_id', filters.brandId);
		}

		// 브랜드명 검색 (레거시)
		if (filters?.brand) {
			query = query.ilike('brand', `%${filters.brand}%`);
		}

		// 가격 필터 (price_range 문자열 파싱 필요 없이 별도 price 컬럼 사용)
		// 참고: equipment 테이블에 numeric price 컬럼이 있다면 사용, 없으면 주석 처리
		// if (filters?.minPrice) {
		// 	query = query.gte('price', filters.minPrice);
		// }
		// if (filters?.maxPrice) {
		// 	query = query.lte('price', filters.maxPrice);
		// }

		if (filters?.minRating) {
			query = query.gte('rating', filters.minRating);
		}

		// 정렬 적용
		const sortBy = filters?.sortBy || 'newest';
		switch (sortBy) {
			case 'newest':
				query = query.order('created_at', { ascending: false });
				break;
			case 'oldest':
				query = query.order('created_at', { ascending: true });
				break;
			case 'rating':
				query = query.order('rating', { ascending: false, nullsFirst: false });
				break;
			case 'popular':
				query = query.order('reviews_count', { ascending: false, nullsFirst: false });
				break;
			default:
				query = query.order('created_at', { ascending: false });
		}

		const { data, error, count } = await query;

		if (error || !data) {
			return { equipment: [], count: 0 };
		}

		const equipment = data.map((item) => ({
			...item,
			category: item.category as EquipmentCategory | undefined
		})) as EquipmentWithCategory[];

		return { equipment, count: count ?? 0 };
	}

	/**
	 * 브랜드로 검색
	 */
	async findByBrand(
		brand: string,
		page = 1,
		pageSize = 20
	): Promise<{ equipment: EquipmentWithCategory[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('equipment')
			.select(
				`
				*,
				category:equipment_categories(
					id,
					name,
					description,
					icon,
					created_at
				)
			`,
				{ count: 'exact' }
			)
			.ilike('brand', `%${brand}%`)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { equipment: [], count: 0 };
		}

		const equipment = data.map((item) => ({
			...item,
			category: item.category as EquipmentCategory | undefined
		})) as EquipmentWithCategory[];

		return { equipment, count: count ?? 0 };
	}

	/**
	 * 장비 생성
	 */
	async create(input: CreateEquipmentInput): Promise<Equipment> {
		const { data, error } = await this.supabase
			.from('equipment')
			.insert({
				brand: input.brand,
				model: input.model,
				category_id: input.category_id ?? null,
				description: input.description ?? null,
				image_url: input.image_url ?? null,
				specs: input.specs ?? null,
				price_range: input.price_range ?? null,
				rating: null,
				reviews_count: 0
			})
			.select()
			.single();

		if (error) throw error;
		return data as Equipment;
	}

	/**
	 * 장비 수정
	 */
	async update(equipmentId: string, updates: Partial<CreateEquipmentInput>): Promise<Equipment> {
		const { data, error } = await this.supabase
			.from('equipment')
			.update({
				...updates,
				updated_at: new Date().toISOString()
			})
			.eq('id', equipmentId)
			.select()
			.single();

		if (error) throw error;
		return data as Equipment;
	}

	/**
	 * 장비 삭제
	 */
	async delete(equipmentId: string): Promise<boolean> {
		const { error } = await this.supabase.from('equipment').delete().eq('id', equipmentId);

		return !error;
	}

	// ==================== Category ====================

	/**
	 * 모든 카테고리 조회
	 */
	async findAllCategories(): Promise<EquipmentCategory[]> {
		const { data, error } = await this.supabase
			.from('equipment_categories')
			.select('*')
			.order('name', { ascending: true });

		if (error || !data) return [];
		return data as EquipmentCategory[];
	}

	/**
	 * 카테고리 ID로 조회
	 */
	async findCategoryById(categoryId: string): Promise<EquipmentCategory | null> {
		const { data, error } = await this.supabase
			.from('equipment_categories')
			.select('*')
			.eq('id', categoryId)
			.single();

		if (error || !data) return null;
		return data as EquipmentCategory;
	}

	// ==================== Reviews ====================

	/**
	 * 장비 리뷰 조회 (작성자 정보 포함)
	 */
	async findReviewsByEquipmentId(
		equipmentId: string,
		page = 1,
		pageSize = 10
	): Promise<{ reviews: EquipmentReviewWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('equipment_reviews')
			.select(
				`
				*,
				author:profiles!user_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.eq('equipment_id', equipmentId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { reviews: [], count: 0 };
		}

		const reviews = data.map((review) => ({
			...review,
			author: review.author as UserProfileSimple
		})) as EquipmentReviewWithAuthor[];

		return { reviews, count: count ?? 0 };
	}

	/**
	 * 리뷰 작성
	 */
	async createReview(
		userId: string,
		equipmentId: string,
		rating: number,
		review: string
	): Promise<EquipmentReview> {
		const { data, error } = await this.supabase
			.from('equipment_reviews')
			.insert({
				user_id: userId,
				equipment_id: equipmentId,
				rating,
				review
			})
			.select()
			.single();

		if (error) throw error;

		// 평균 평점 재계산
		await this.updateAverageRating(equipmentId);

		return data as EquipmentReview;
	}

	/**
	 * 리뷰 수정
	 */
	async updateReview(
		reviewId: string,
		userId: string,
		updates: { rating?: number; review?: string }
	): Promise<EquipmentReview> {
		const { data, error } = await this.supabase
			.from('equipment_reviews')
			.update({
				...updates,
				updated_at: new Date().toISOString()
			})
			.eq('id', reviewId)
			.eq('user_id', userId) // 작성자만 수정 가능
			.select()
			.single();

		if (error) throw error;

		// 평균 평점 재계산
		const review = data as EquipmentReview;
		await this.updateAverageRating(review.equipment_id);

		return review;
	}

	/**
	 * 리뷰 삭제
	 */
	async deleteReview(reviewId: string, userId: string): Promise<boolean> {
		// 먼저 리뷰 정보 가져오기 (equipment_id 필요)
		const { data: review } = await this.supabase
			.from('equipment_reviews')
			.select('equipment_id')
			.eq('id', reviewId)
			.eq('user_id', userId)
			.single();

		const { error } = await this.supabase
			.from('equipment_reviews')
			.delete()
			.eq('id', reviewId)
			.eq('user_id', userId); // 작성자만 삭제 가능

		if (!error && review) {
			// 평균 평점 재계산
			await this.updateAverageRating(review.equipment_id);
		}

		return !error;
	}

	/**
	 * 평균 평점 재계산 (내부 함수)
	 */
	private async updateAverageRating(equipmentId: string): Promise<void> {
		const { data } = await this.supabase
			.from('equipment_reviews')
			.select('rating')
			.eq('equipment_id', equipmentId);

		if (data && data.length > 0) {
			const validRatings = data.filter((r) => r.rating !== null).map((r) => r.rating);
			const avgRating =
				validRatings.length > 0
					? validRatings.reduce((sum, r) => sum + r, 0) / validRatings.length
					: null;

			await this.supabase
				.from('equipment')
				.update({
					rating: avgRating,
					reviews_count: data.length
				})
				.eq('id', equipmentId);
		} else {
			await this.supabase
				.from('equipment')
				.update({
					rating: null,
					reviews_count: 0
				})
				.eq('id', equipmentId);
		}
	}
}
