import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { RecipeRepository } from '$lib/server/database/Repository/recipe.repository';

/**
 * GET /api/recipes
 * 레시피 목록 조회
 * Query params: page, page_size, brew_method, difficulty, popular, search
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();
	const currentUserId = user?.id;

	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '20');
	const brewMethod = url.searchParams.get('brew_method');
	const difficulty = url.searchParams.get('difficulty') as 'easy' | 'medium' | 'hard' | null;
	const popular = url.searchParams.get('popular') === 'true';
	const search = url.searchParams.get('search');

	const recipeRepo = new RecipeRepository(supabase);

	try {
		let result;

		if (search) {
			// 검색
			result = await recipeRepo.search(search, page, pageSize);
		} else if (popular) {
			// 인기 레시피
			result = await recipeRepo.findPopular(page, pageSize);
		} else if (brewMethod) {
			// 추출 방법별
			result = await recipeRepo.findByBrewMethod(brewMethod, page, pageSize);
		} else if (difficulty) {
			// 난이도별
			result = await recipeRepo.findByDifficulty(difficulty, page, pageSize);
		} else {
			// 전체
			result = await recipeRepo.findAll(page, pageSize, currentUserId);
		}

		return json({
			success: true,
			data: result.recipes,
			pagination: {
				page,
				page_size: pageSize,
				total_count: result.count,
				total_pages: Math.ceil(result.count / pageSize)
			}
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * POST /api/recipes
 * 레시피 생성
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const body = await request.json();

	// 유효성 검사
	if (!body.title || body.title.trim().length === 0) {
		return svelteError(400, 'Title is required');
	}

	if (!body.ingredients) {
		return svelteError(400, 'Ingredients are required');
	}

	const recipeRepo = new RecipeRepository(supabase);

	try {
		const recipe = await recipeRepo.create(userId, body);

		return json({
			success: true,
			data: recipe
		}, { status: 201 });
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
