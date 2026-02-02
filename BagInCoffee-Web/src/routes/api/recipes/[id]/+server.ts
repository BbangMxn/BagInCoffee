import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { RecipeRepository } from '$lib/server/database/Repository/recipe.repository';

/**
 * GET /api/recipes/[id]
 * 특정 레시피 조회
 */
export const GET: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();
	const currentUserId = user?.id;

	const recipeRepo = new RecipeRepository(supabase);

	try {
		const recipe = await recipeRepo.findById(params.id, currentUserId);

		if (!recipe) {
			return svelteError(404, 'Recipe not found');
		}

		return json({
			success: true,
			data: recipe
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * PATCH /api/recipes/[id]
 * 레시피 수정
 */
export const PATCH: RequestHandler = async ({ params, request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const body = await request.json();

	const recipeRepo = new RecipeRepository(supabase);

	try {
		const recipe = await recipeRepo.update(params.id, userId, body);

		return json({
			success: true,
			data: recipe
		});
	} catch (err: any) {
		return svelteError(403, 'Forbidden or not found');
	}
};

/**
 * DELETE /api/recipes/[id]
 * 레시피 삭제
 */
export const DELETE: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const recipeRepo = new RecipeRepository(supabase);

	try {
		const success = await recipeRepo.delete(params.id, userId);

		if (!success) {
			return svelteError(403, 'Forbidden or not found');
		}

		return json({
			success: true,
			message: 'Recipe deleted'
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
