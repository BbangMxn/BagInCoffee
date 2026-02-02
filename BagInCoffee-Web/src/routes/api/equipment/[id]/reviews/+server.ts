import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { EquipmentRepository } from '$lib/server/database/Repository/equipment.repository';

/**
 * GET /api/equipment/[id]/reviews
 * 장비 리뷰 목록 조회
 */
export const GET: RequestHandler = async ({ params, url, locals: { supabase } }) => {
	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '10');

	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const result = await equipmentRepo.findReviewsByEquipmentId(params.id, page, pageSize);

		return json({
			success: true,
			data: result.reviews,
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
 * POST /api/equipment/[id]/reviews
 * 리뷰 작성
 */
export const POST: RequestHandler = async ({ params, request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const equipmentId = params.id;
	const body = await request.json();

	// 유효성 검사
	if (!body.rating || body.rating < 1 || body.rating > 5) {
		return svelteError(400, 'Rating must be between 1 and 5');
	}

	if (!body.review || body.review.trim().length === 0) {
		return svelteError(400, 'Review content is required');
	}

	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const review = await equipmentRepo.createReview(
			userId,
			equipmentId,
			body.rating,
			body.review
		);

		return json({
			success: true,
			data: review
		}, { status: 201 });
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
