import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { CommentRepository } from '$lib/server/database/Repository/comment.repository';

/**
 * GET /api/posts/[id]/comments
 * 게시물의 댓글 목록 조회
 */
export const GET: RequestHandler = async ({ params, url, locals: { supabase } }) => {
	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '20');

	const commentRepo = new CommentRepository(supabase);

	try {
		const result = await commentRepo.findByPostId(params.id, page, pageSize);

		return json({
			success: true,
			data: result.comments,
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
 * POST /api/posts/[id]/comments
 * 댓글 작성
 */
export const POST: RequestHandler = async ({ params, request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const postId = params.id;
	const body = await request.json();

	if (!body.content || body.content.trim().length === 0) {
		return svelteError(400, 'Content is required');
	}

	const commentRepo = new CommentRepository(supabase);

	try {
		const comment = await commentRepo.create(userId, postId, body.content);

		return json({
			success: true,
			data: comment
		}, { status: 201 });
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
