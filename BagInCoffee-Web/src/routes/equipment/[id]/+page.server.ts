import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import { EquipmentRepository } from '$lib/server/database/Repository/equipment.repository';

export const load: PageServerLoad = async ({ params, locals: { supabase } }) => {
	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		// 장비 상세 정보 조회
		const equipment = await equipmentRepo.findById(params.id);

		if (!equipment) {
			throw error(404, '장비를 찾을 수 없습니다.');
		}

		// 리뷰 조회 (첫 페이지만)
		const { reviews, count: reviewCount } = await equipmentRepo.findReviewsByEquipmentId(
			params.id,
			1,
			10
		);

		return {
			equipment,
			reviews,
			reviewCount
		};
	} catch (err: any) {
		console.error('Equipment detail page load error:', err);
		throw error(500, '장비 정보를 불러오는데 실패했습니다.');
	}
};
