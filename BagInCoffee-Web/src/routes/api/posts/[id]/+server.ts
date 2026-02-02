import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { PostRepository } from '$lib/server/database/Repository/post.repository';

/**
 * GET /api/posts/[id]
 * 특정 게시물 조회
 */
export const GET: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();
	const currentUserId = user?.id;

	const postRepo = new PostRepository(supabase);

	try {
		const post = await postRepo.findById(params.id, currentUserId);

		if (!post) {
			return svelteError(404, 'Post not found');
		}

		return json({
			success: true,
			data: post
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * PATCH /api/posts/[id]
 * 게시물 수정
 */
export const PATCH: RequestHandler = async ({ params, request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const body = await request.json();

	const postRepo = new PostRepository(supabase);

	try {
		const post = await postRepo.update(params.id, userId, body);

		return json({
			success: true,
			data: post
		});
	} catch (err: any) {
		// 권한 없음 또는 찾을 수 없음
		return svelteError(403, 'Forbidden or not found');
	}
};

/**
 * DELETE /api/posts/[id]
 * 게시물 삭제
 */
export const DELETE: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const postRepo = new PostRepository(supabase);

	try {
		const success = await postRepo.delete(params.id, userId);

		if (!success) {
			return svelteError(403, 'Forbidden or not found');
		}

		return json({
			success: true,
			message: 'Post deleted'
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
