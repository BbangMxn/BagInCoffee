import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { EquipmentRepository } from '$lib/server/database/Repository/equipment.repository';

/**
 * GET /api/equipment/categories
 * 모든 장비 카테고리 조회
 */
export const GET: RequestHandler = async ({ locals: { supabase } }) => {
	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const categories = await equipmentRepo.findAllCategories();

		return json({
			success: true,
			data: categories
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
