import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { GuideRepository } from '$lib/server/database/Repository/guide.repository';

/**
 * GET /api/guide/[id]
 * 특정 가이드 조회 (마크다운 콘텐츠 포함)
 */
export const GET: RequestHandler = async ({ params, locals: { supabase } }) => {
	const guideRepo = new GuideRepository(supabase);

	try {
		const guide = await guideRepo.findById(params.id);

		if (!guide) {
			return svelteError(404, 'Guide not found');
		}

		// 조회수 증가
		await guideRepo.incrementViews(params.id);

		return json({
			success: true,
			data: guide
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * PATCH /api/guide/[id]
 * 가이드 수정 (작성자만 가능)
 */
export const PATCH: RequestHandler = async ({ params, request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const guideRepo = new GuideRepository(supabase);

	try {
		const guide = await guideRepo.findById(params.id);

		if (!guide) {
			return svelteError(404, 'Guide not found');
		}

		// 작성자 체크
		if (guide.author_id !== user.id) {
			return svelteError(403, 'Forbidden');
		}

		const body = await request.json();
		const updated = await guideRepo.update(params.id, body);

		return json({
			success: true,
			data: updated
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * DELETE /api/guide/[id]
 * 가이드 삭제 (작성자만 가능)
 */
export const DELETE: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const guideRepo = new GuideRepository(supabase);

	try {
		const guide = await guideRepo.findById(params.id);

		if (!guide) {
			return svelteError(404, 'Guide not found');
		}

		// 작성자 체크
		if (guide.author_id !== user.id) {
			return svelteError(403, 'Forbidden');
		}

		await guideRepo.delete(params.id);

		return json({
			success: true,
			data: { message: 'Guide deleted successfully' }
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
