import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { EquipmentRepository } from '$lib/server/database/Repository/equipment.repository';

/**
 * GET /api/equipment/[id]
 * 특정 장비 상세 조회 (브랜드 및 카테고리 정보 포함)
 */
export const GET: RequestHandler = async ({ params, locals: { supabase } }) => {
	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const equipment = await equipmentRepo.findById(params.id);

		if (!equipment) {
			return svelteError(404, 'Equipment not found');
		}

		return json({
			success: true,
			data: equipment
		});
	} catch (err: any) {
		console.error('Equipment detail error:', err);
		return svelteError(500, err.message);
	}
};

/**
 * PATCH /api/equipment/[id]
 * 장비 수정 (관리자만)
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
	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const equipment = await equipmentRepo.update(params.id, body);

		return json({
			success: true,
			data: equipment
		});
	} catch (err: any) {
		console.error('Equipment update error:', err);
		return svelteError(500, err.message);
	}
};

/**
 * DELETE /api/equipment/[id]
 * 장비 삭제 (관리자만)
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

	const equipmentRepo = new EquipmentRepository(supabase);

	try {
		const success = await equipmentRepo.delete(params.id);

		if (!success) {
			return svelteError(404, 'Equipment not found');
		}

		return json({
			success: true,
			data: { message: 'Equipment deleted successfully' }
		});
	} catch (err: any) {
		console.error('Equipment delete error:', err);
		return svelteError(500, err.message);
	}
};
