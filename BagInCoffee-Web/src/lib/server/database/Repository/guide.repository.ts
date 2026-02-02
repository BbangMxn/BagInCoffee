import type { SupabaseClient } from '@supabase/supabase-js';
import type { CoffeeGuide, GuideCategory } from '$lib/types/content';

/**
 * 📚 CoffeeGuide Repository
 *
 * 커피 가이드 관련 DB 작업
 * - 마크다운 콘텐츠 저장 및 조회
 * - 카테고리별 필터링
 * - 난이도별 정렬
 */
export class GuideRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 모든 가이드 조회 (페이지네이션 + 필터)
	 */
	async findAll(
		page = 1,
		pageSize = 10,
		filters?: {
			category?: GuideCategory;
			difficulty?: CoffeeGuide['difficulty'];
		}
	): Promise<{
		data: CoffeeGuide[];
		total: number;
		page: number;
		pageSize: number;
	}> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		let query = this.supabase
			.from('coffee_guides')
			.select('*', { count: 'exact' })
			.order('created_at', { ascending: false });

		// 필터 적용
		if (filters?.category) {
			query = query.eq('category', filters.category);
		}
		if (filters?.difficulty) {
			query = query.eq('difficulty', filters.difficulty);
		}

		const { data, error, count } = await query.range(from, to);

		if (error) throw new Error(`Failed to fetch guides: ${error.message}`);

		return {
			data: (data as CoffeeGuide[]) || [],
			total: count || 0,
			page,
			pageSize
		};
	}

	/**
	 * 특정 가이드 조회 (마크다운 콘텐츠 포함)
	 */
	async findById(id: string): Promise<CoffeeGuide | null> {
		const { data, error } = await this.supabase
			.from('coffee_guides')
			.select('*')
			.eq('id', id)
			.single();

		if (error) {
			if (error.code === 'PGRST116') return null; // Not found
			throw new Error(`Failed to fetch guide: ${error.message}`);
		}

		return data as CoffeeGuide;
	}

	/**
	 * 가이드 생성
	 */
	async create(
		input: Omit<CoffeeGuide, 'id' | 'created_at' | 'updated_at'>
	): Promise<CoffeeGuide> {
		const { data, error } = await this.supabase
			.from('coffee_guides')
			.insert(input)
			.select()
			.single();

		if (error) throw new Error(`Failed to create guide: ${error.message}`);

		return data as CoffeeGuide;
	}

	/**
	 * 가이드 수정
	 */
	async update(
		id: string,
		updates: Partial<Omit<CoffeeGuide, 'id' | 'created_at' | 'updated_at' | 'author_id'>>
	): Promise<CoffeeGuide> {
		const { data, error } = await this.supabase
			.from('coffee_guides')
			.update({ ...updates, updated_at: new Date().toISOString() })
			.eq('id', id)
			.select()
			.single();

		if (error) throw new Error(`Failed to update guide: ${error.message}`);

		return data as CoffeeGuide;
	}

	/**
	 * 가이드 삭제
	 */
	async delete(id: string): Promise<void> {
		const { error } = await this.supabase.from('coffee_guides').delete().eq('id', id);

		if (error) throw new Error(`Failed to delete guide: ${error.message}`);
	}

	/**
	 * 조회수 증가
	 */
	async incrementViews(id: string): Promise<void> {
		const { error } = await this.supabase.rpc('increment_guide_views', { guide_id: id });

		if (error) {
			// RPC가 없으면 수동으로 증가
			const guide = await this.findById(id);
			if (guide) {
				await this.supabase
					.from('coffee_guides')
					.update({ views_count: (guide.views_count || 0) + 1 })
					.eq('id', id);
			}
		}
	}

	/**
	 * 인기 가이드 조회 (조회수 기준)
	 */
	async findPopular(limit = 5): Promise<CoffeeGuide[]> {
		const { data, error } = await this.supabase
			.from('coffee_guides')
			.select('*')
			.order('views_count', { ascending: false })
			.limit(limit);

		if (error) throw new Error(`Failed to fetch popular guides: ${error.message}`);

		return (data as CoffeeGuide[]) || [];
	}

	/**
	 * 카테고리별 가이드 수 조회
	 */
	async countByCategory(): Promise<Record<GuideCategory, number>> {
		const { data, error } = await this.supabase
			.from('coffee_guides')
			.select('category')
			.order('category');

		if (error) throw new Error(`Failed to count guides: ${error.message}`);

		const counts: Record<string, number> = {};
		data?.forEach((item) => {
			counts[item.category] = (counts[item.category] || 0) + 1;
		});

		return counts as Record<GuideCategory, number>;
	}
}
