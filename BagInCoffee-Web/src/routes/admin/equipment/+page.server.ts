import type { PageServerLoad } from './$types';
import { error, redirect } from '@sveltejs/kit';
import { EquipmentRepository } from '$lib/server/database/Repository/equipment.repository';
import { BrandRepository } from '$lib/server/database/Repository/brand.repository';

export const load: PageServerLoad = async ({ locals: { supabase, getSession } }) => {
	const session = await getSession();

	if (!session) {
		throw redirect(303, '/login');
	}

	// 관리자 권한 체크
	const { data: profile } = await supabase
		.from('profiles')
		.select('role')
		.eq('id', session.user.id)
		.single();

	if (profile?.role !== 'admin') {
		throw error(403, '관리자만 접근할 수 있습니다.');
	}

	const equipmentRepo = new EquipmentRepository(supabase);
	const brandRepo = new BrandRepository(supabase);

	// 전체 장비 조회 (페이지네이션 없이)
	const { equipment, count } = await equipmentRepo.findAll(1, 1000);

	// 전체 카테고리 조회
	const categories = await equipmentRepo.findAllCategories();

	// 전체 브랜드 조회
	const brands = await brandRepo.findAll();

	return {
		equipment,
		categories,
		brands,
		totalCount: count
	};
};
