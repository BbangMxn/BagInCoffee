import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { PostRepository } from '$lib/server/database/Repository/post.repository';

/**
 * GET /api/posts
 * 게시물 목록 조회 (피드)
 * Query params: page, page_size, tag, user_id
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();
	const currentUserId = user?.id;

	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '20');
	const tag = url.searchParams.get('tag');
	const userId = url.searchParams.get('user_id');

	const postRepo = new PostRepository(supabase);

	try {
		let result;

		if (tag) {
			// 태그로 필터링
			result = await postRepo.findByTag(tag, page, pageSize);
		} else if (userId) {
			// 특정 사용자의 게시물
			result = await postRepo.findByUserId(userId, page, pageSize);
		} else {
			// 전체 피드
			result = await postRepo.findFeed(page, pageSize, currentUserId);
		}

		return json({
			success: true,
			data: result.posts,
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
 * POST /api/posts
 * 게시물 생성
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const body = await request.json();

	// 유효성 검사
	if (!body.content || body.content.trim().length === 0) {
		return svelteError(400, 'Content is required');
	}

	const postRepo = new PostRepository(supabase);

	try {
		const post = await postRepo.create(userId, {
			content: body.content,
			images: body.images,
			tags: body.tags
		});

		return json({
			success: true,
			data: post
		}, { status: 201 });
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
