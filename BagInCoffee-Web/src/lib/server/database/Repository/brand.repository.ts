import type { SupabaseClient } from '@supabase/supabase-js';
import type { Brand, BrandWithCategories, CreateBrandInput } from '$lib/types/equipment';

/**
 * 브랜드 Repository
 * brands 테이블 관리
 */
export class BrandRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 모든 브랜드 조회
	 * @param options - 필터 옵션
	 * @returns 브랜드 목록
	 */
	async findAll(options?: {
		country?: string;
		search?: string;
		categoryId?: string;
	}): Promise<Brand[]> {
		let query = this.supabase
			.from('brands')
			.select('*')
			.order('name', { ascending: true });

		// 국가 필터
		if (options?.country) {
			query = query.eq('country', options.country);
		}

		// 검색 (이름)
		if (options?.search) {
			query = query.or(`name.ilike.%${options.search}%,name_en.ilike.%${options.search}%`);
		}

		// 카테고리별 필터 (brand_categories 조인)
		if (options?.categoryId) {
			const { data: brandCategories } = await this.supabase
				.from('brand_categories')
				.select('brand_id')
				.eq('category_id', options.categoryId);

			if (brandCategories && brandCategories.length > 0) {
				const brandIds = brandCategories.map((bc) => bc.brand_id);
				query = query.in('id', brandIds);
			} else {
				// 해당 카테고리에 브랜드가 없으면 빈 배열 반환
				return [];
			}
		}

		const { data, error } = await query;

		if (error) throw error;
		return data || [];
	}

	/**
	 * ID로 브랜드 조회 (카테고리 포함)
	 * @param id - 브랜드 ID
	 * @returns 브랜드 + 카테고리 정보
	 */
	async findById(id: string): Promise<BrandWithCategories | null> {
		const { data: brand, error } = await this.supabase
			.from('brands')
			.select('*')
			.eq('id', id)
			.single();

		if (error) throw error;
		if (!brand) return null;

		// 브랜드의 카테고리 조회
		const { data: brandCategories } = await this.supabase
			.from('brand_categories')
			.select(
				`
				category_id,
				equipment_categories (
					id,
					name,
					description,
					icon,
					created_at
				)
			`
			)
			.eq('brand_id', id);

		const categories = brandCategories
			?.map((bc: any) => bc.equipment_categories)
			.filter(Boolean);

		return {
			...brand,
			categories: categories || []
		};
	}

	/**
	 * 브랜드 생성
	 * @param input - 브랜드 정보
	 * @returns 생성된 브랜드
	 */
	async create(input: CreateBrandInput): Promise<Brand> {
		const { data, error } = await this.supabase
			.from('brands')
			.insert({
				name: input.name,
				name_en: input.name_en,
				description: input.description,
				logo_url: input.logo_url,
				website: input.website,
				country: input.country,
				founded_year: input.founded_year
			})
			.select()
			.single();

		if (error) throw error;
		return data;
	}

	/**
	 * 브랜드 수정
	 * @param id - 브랜드 ID
	 * @param updates - 수정할 필드
	 * @returns 수정된 브랜드
	 */
	async update(id: string, updates: Partial<CreateBrandInput>): Promise<Brand> {
		const { data, error } = await this.supabase
			.from('brands')
			.update({
				...updates,
				updated_at: new Date().toISOString()
			})
			.eq('id', id)
			.select()
			.single();

		if (error) throw error;
		return data;
	}

	/**
	 * 브랜드 삭제
	 * @param id - 브랜드 ID
	 */
	async delete(id: string): Promise<void> {
		const { error } = await this.supabase.from('brands').delete().eq('id', id);

		if (error) throw error;
	}

	/**
	 * 브랜드에 카테고리 추가
	 * @param brandId - 브랜드 ID
	 * @param categoryId - 카테고리 ID
	 */
	async addCategory(brandId: string, categoryId: string): Promise<void> {
		const { error } = await this.supabase.from('brand_categories').insert({
			brand_id: brandId,
			category_id: categoryId
		});

		if (error) throw error;
	}

	/**
	 * 브랜드에서 카테고리 제거
	 * @param brandId - 브랜드 ID
	 * @param categoryId - 카테고리 ID
	 */
	async removeCategory(brandId: string, categoryId: string): Promise<void> {
		const { error } = await this.supabase
			.from('brand_categories')
			.delete()
			.eq('brand_id', brandId)
			.eq('category_id', categoryId);

		if (error) throw error;
	}

	/**
	 * 국가별 브랜드 수 조회
	 * @returns 국가별 브랜드 개수
	 */
	async getCountryStats(): Promise<Record<string, number>> {
		const { data, error } = await this.supabase
			.from('brands')
			.select('country')
			.not('country', 'is', null);

		if (error) throw error;

		const stats: Record<string, number> = {};
		data?.forEach((brand) => {
			if (brand.country) {
				stats[brand.country] = (stats[brand.country] || 0) + 1;
			}
		});

		return stats;
	}
}
