import type { SupabaseClient } from '@supabase/supabase-js';
import type { Recipe, RecipeWithAuthor, CreateRecipeInput } from '$lib/types/recipe';
import type { UserProfileSimple } from '$lib/types/user';

export class RecipeRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 레시피 ID로 조회 (작성자 정보 포함)
	 */
	async findById(recipeId: string, currentUserId?: string): Promise<RecipeWithAuthor | null> {
		const { data, error } = await this.supabase
			.from('recipes')
			.select(
				`
				*,
				author:profiles!user_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`
			)
			.eq('id', recipeId)
			.single();

		if (error || !data) return null;

		// hasLiked 확인
		let hasLiked = false;
		if (currentUserId) {
			const { data: likeData } = await this.supabase
				.from('likes')
				.select('id')
				.eq('recipe_id', recipeId)
				.eq('user_id', currentUserId)
				.single();

			hasLiked = !!likeData;
		}

		return {
			...data,
			author: data.author as UserProfileSimple,
			hasLiked
		} as RecipeWithAuthor;
	}

	/**
	 * 레시피 목록 조회 (페이지네이션)
	 */
	async findAll(
		page = 1,
		pageSize = 20,
		currentUserId?: string
	): Promise<{ recipes: RecipeWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('recipes')
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
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { recipes: [], count: 0 };
		}

		// hasLiked 확인 (bulk)
		let likedRecipeIds: Set<string> = new Set();
		if (currentUserId && data.length > 0) {
			const recipeIds = data.map((r) => r.id);
			const { data: likesData } = await this.supabase
				.from('likes')
				.select('recipe_id')
				.eq('user_id', currentUserId)
				.in('recipe_id', recipeIds);

			if (likesData) {
				likedRecipeIds = new Set(likesData.map((l) => l.recipe_id));
			}
		}

		const recipes = data.map((recipe) => ({
			...recipe,
			author: recipe.author as UserProfileSimple,
			hasLiked: likedRecipeIds.has(recipe.id)
		})) as RecipeWithAuthor[];

		return { recipes, count: count ?? 0 };
	}

	/**
	 * 특정 사용자의 레시피 조회
	 */
	async findByUserId(
		userId: string,
		page = 1,
		pageSize = 20
	): Promise<{ recipes: Recipe[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('recipes')
			.select('*', { count: 'exact' })
			.eq('user_id', userId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { recipes: [], count: 0 };
		}

		return { recipes: data as Recipe[], count: count ?? 0 };
	}

	/**
	 * 추출 방법으로 필터링
	 */
	async findByBrewMethod(
		brewMethod: string,
		page = 1,
		pageSize = 20
	): Promise<{ recipes: RecipeWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('recipes')
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
			.eq('brew_method', brewMethod)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { recipes: [], count: 0 };
		}

		const recipes = data.map((recipe) => ({
			...recipe,
			author: recipe.author as UserProfileSimple,
			hasLiked: false
		})) as RecipeWithAuthor[];

		return { recipes, count: count ?? 0 };
	}

	/**
	 * 난이도로 필터링
	 */
	async findByDifficulty(
		difficulty: 'easy' | 'medium' | 'hard',
		page = 1,
		pageSize = 20
	): Promise<{ recipes: RecipeWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('recipes')
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
			.eq('difficulty', difficulty)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { recipes: [], count: 0 };
		}

		const recipes = data.map((recipe) => ({
			...recipe,
			author: recipe.author as UserProfileSimple,
			hasLiked: false
		})) as RecipeWithAuthor[];

		return { recipes, count: count ?? 0 };
	}

	/**
	 * 레시피 검색 (제목 기반)
	 */
	async search(
		query: string,
		page = 1,
		pageSize = 20
	): Promise<{ recipes: RecipeWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('recipes')
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
			.ilike('title', `%${query}%`)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { recipes: [], count: 0 };
		}

		const recipes = data.map((recipe) => ({
			...recipe,
			author: recipe.author as UserProfileSimple,
			hasLiked: false
		})) as RecipeWithAuthor[];

		return { recipes, count: count ?? 0 };
	}

	/**
	 * 레시피 생성
	 */
	async create(userId: string, input: CreateRecipeInput): Promise<Recipe> {
		const { data, error } = await this.supabase
			.from('recipes')
			.insert({
				user_id: userId,
				title: input.title,
				ingredients: input.ingredients,
				instructions: input.instructions ?? null,
				brew_method: input.brew_method ?? null,
				brew_time: input.brew_time ?? null,
				difficulty: input.difficulty ?? null,
				image_url: input.image_url ?? null,
				likes_count: 0
			})
			.select()
			.single();

		if (error) throw error;
		return data as Recipe;
	}

	/**
	 * 레시피 수정
	 */
	async update(
		recipeId: string,
		userId: string,
		updates: Partial<CreateRecipeInput>
	): Promise<Recipe> {
		const { data, error } = await this.supabase
			.from('recipes')
			.update({
				...updates,
				updated_at: new Date().toISOString()
			})
			.eq('id', recipeId)
			.eq('user_id', userId) // 작성자만 수정 가능
			.select()
			.single();

		if (error) throw error;
		return data as Recipe;
	}

	/**
	 * 레시피 삭제
	 */
	async delete(recipeId: string, userId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('recipes')
			.delete()
			.eq('id', recipeId)
			.eq('user_id', userId); // 작성자만 삭제 가능

		return !error;
	}

	/**
	 * 좋아요 수 증가
	 */
	async incrementLikes(recipeId: string): Promise<void> {
		await this.supabase.rpc('increment_recipe_likes', { recipe_id: recipeId });
	}

	/**
	 * 좋아요 수 감소
	 */
	async decrementLikes(recipeId: string): Promise<void> {
		await this.supabase.rpc('decrement_recipe_likes', { recipe_id: recipeId });
	}

	/**
	 * 인기 레시피 조회 (좋아요 순)
	 */
	async findPopular(
		page = 1,
		pageSize = 20
	): Promise<{ recipes: RecipeWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('recipes')
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
			.order('likes_count', { ascending: false })
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { recipes: [], count: 0 };
		}

		const recipes = data.map((recipe) => ({
			...recipe,
			author: recipe.author as UserProfileSimple,
			hasLiked: false
		})) as RecipeWithAuthor[];

		return { recipes, count: count ?? 0 };
	}
}
