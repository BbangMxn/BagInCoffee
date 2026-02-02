import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { GuideRepository } from '$lib/server/database/Repository/guide.repository';
import type { GuideCategory } from '$lib/types/content';

/**
 * GET /api/guide
 * 커피 가이드 목록 조회
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const guideRepo = new GuideRepository(supabase);

	try {
		const page = parseInt(url.searchParams.get('page') || '1');
		const pageSize = parseInt(url.searchParams.get('page_size') || '10');
		const category = url.searchParams.get('category') as GuideCategory | null;
		const difficulty = url.searchParams.get('difficulty') as
			| 'beginner'
			| 'intermediate'
			| 'advanced'
			| 'master'
			| null;

		const result = await guideRepo.findAll(page, pageSize, {
			...(category && { category }),
			...(difficulty && { difficulty })
		});

		return json({
			success: true,
			data: result.data,
			pagination: {
				page: result.page,
				page_size: result.pageSize,
				total: result.total,
				total_pages: Math.ceil(result.total / result.pageSize)
			}
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * POST /api/guide
 * 커피 가이드 생성 (인증 필요)
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const guideRepo = new GuideRepository(supabase);

	try {
		const body = await request.json();

		const guide = await guideRepo.create({
			...body,
			author_id: user.id
		});

		return json({
			success: true,
			data: guide
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
