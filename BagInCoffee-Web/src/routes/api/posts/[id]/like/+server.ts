import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { LikeRepository } from '$lib/server/database/Repository/like.repository';

/**
 * POST /api/posts/[id]/like
 * 좋아요 토글 (있으면 제거, 없으면 추가)
 */
export const POST: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const postId = params.id;

	const likeRepo = new LikeRepository(supabase);

	try {
		const result = await likeRepo.toggleLike(userId, postId);

		return json({
			success: true,
			data: {
				liked: result.added,
				like: result.like
			}
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
