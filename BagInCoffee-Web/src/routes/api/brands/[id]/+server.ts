import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { BrandRepository } from '$lib/server/database/Repository/brand.repository';

/**
 * GET /api/brands/[id]
 * 브랜드 상세 조회 (카테고리 포함)
 */
export const GET: RequestHandler = async ({ params, locals: { supabase } }) => {
	const brandRepo = new BrandRepository(supabase);

	try {
		const brand = await brandRepo.findById(params.id);

		if (!brand) {
			return svelteError(404, 'Brand not found');
		}

		return json({
			success: true,
			data: brand
		});
	} catch (err: any) {
		console.error('Brand detail error:', err);
		return svelteError(500, err.message);
	}
};

/**
 * PATCH /api/brands/[id]
 * 브랜드 수정 (관리자만)
 */
export const PATCH: RequestHandler = async ({ params, request, locals: { supabase } }) => {
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
	const brandRepo = new BrandRepository(supabase);

	try {
		const brand = await brandRepo.update(params.id, body);

		return json({
			success: true,
			data: brand
		});
	} catch (err: any) {
		console.error('Brand update error:', err);
		return svelteError(500, err.message);
	}
};

/**
 * DELETE /api/brands/[id]
 * 브랜드 삭제 (관리자만)
 */
export const DELETE: RequestHandler = async ({ params, locals: { supabase } }) => {
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

	const brandRepo = new BrandRepository(supabase);

	try {
		await brandRepo.delete(params.id);

		return json({
			success: true,
			data: { message: 'Brand deleted successfully' }
		});
	} catch (err: any) {
		console.error('Brand delete error:', err);
		return svelteError(500, err.message);
	}
};
