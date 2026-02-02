import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { EquipmentRepository } from '$lib/server/database/Repository/equipment.repository';

/**
 * GET /api/equipment
 * 장비 목록 조회 (브랜드 정보 포함)
 * Query params: page, page_size, category_id, brand_id, brand, min_rating, sort_by
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '20');
	const categoryId = url.searchParams.get('category_id') || undefined;
	const brandId = url.searchParams.get('brand_id') || undefined;
	const brand = url.searchParams.get('brand') || undefined;
	const minRating = url.searchParams.get('min_rating')
		? parseFloat(url.searchParams.get('min_rating')!)
		: undefined;
	const sortBy = (url.searchParams.get('sort_by') ||
		'newest') as 'newest' | 'oldest' | 'price_low' | 'price_high' | 'rating' | 'popular';

	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const result = await equipmentRepo.findAll(page, pageSize, {
			...(categoryId && { categoryId }),
			...(brandId && { brandId }),
			...(brand && { brand }),
			...(minRating && { minRating }),
			sortBy
		});

		return json({
			success: true,
			data: result.equipment,
			pagination: {
				page,
				page_size: pageSize,
				total_count: result.count,
				total_pages: Math.ceil(result.count / pageSize)
			}
		});
	} catch (err: any) {
		console.error('Equipment list error:', err);
		return svelteError(500, err.message);
	}
};

/**
 * POST /api/equipment
 * 장비 생성 (관리자만)
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	// 관리자 권한 체크
	const { data: profile } = await supabase
		.from('profiles')
		.select('role')
		.eq('id', user.id)
		.single();

	if (profile?.role !== 'admin') {
		return svelteError(403, 'Admin only');
	}

	const body = await request.json();

	// 유효성 검사
	if (!body.model) {
		return svelteError(400, 'Model is required');
	}

	if (!body.brand_id && !body.brand) {
		return svelteError(400, 'Either brand_id or brand is required');
	}

	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const equipment = await equipmentRepo.create(body);

		return json(
			{
				success: true,
				data: equipment
			},
			{ status: 201 }
		);
	} catch (err: any) {
		console.error('Equipment create error:', err);
		return svelteError(500, err.message);
	}
};
