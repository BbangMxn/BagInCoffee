import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { BrandRepository } from '$lib/server/database/Repository/brand.repository';

/**
 * GET /api/brands
 * 브랜드 목록 조회
 * Query params: country, search, category_id
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const country = url.searchParams.get('country') || undefined;
	const search = url.searchParams.get('search') || undefined;
	const categoryId = url.searchParams.get('category_id') || undefined;

	const brandRepo = new BrandRepository(supabase);

	try {
		const brands = await brandRepo.findAll({
			country,
			search,
			categoryId
		});

		return json({
			success: true,
			data: brands
		});
	} catch (err: any) {
		console.error('Brand list error:', err);
		return svelteError(500, err.message);
	}
};

/**
 * POST /api/brands
 * 브랜드 생성 (관리자만)
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
	if (!body.name) {
		return svelteError(400, 'Brand name is required');
	}

	const brandRepo = new BrandRepository(supabase);

	try {
		const brand = await brandRepo.create(body);

		return json(
			{
				success: true,
				data: brand
			},
			{ status: 201 }
		);
	} catch (err: any) {
		console.error('Brand create error:', err);
		return svelteError(500, err.message);
	}
};
