import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { BrandRepository } from '$lib/server/database/Repository/brand.repository';

/**
 * GET /api/brands/stats
 * 브랜드 통계 조회 (국가별 브랜드 수)
 */
export const GET: RequestHandler = async ({ locals: { supabase } }) => {
	const brandRepo = new BrandRepository(supabase);

	try {
		const stats = await brandRepo.getCountryStats();

		return json({
			success: true,
			data: stats
		});
	} catch (err: any) {
		console.error('Brand stats error:', err);
		return svelteError(500, err.message);
	}
};
