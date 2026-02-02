import type { PageLoad } from './$types';
import { brandApi } from '$lib/api/brand';
import { error } from '@sveltejs/kit';

export const load: PageLoad = async ({ parent }) => {
	const { profile } = await parent();

	// 관리자 권한 확인
	if (profile.role !== 'admin' && profile.role !== 'moderator') {
		throw error(403, '접근 권한이 없습니다.');
	}

	// 브랜드 목록 가져오기
	const brandsResponse = await brandApi.getAll();

	if (!brandsResponse.success) {
		throw error(500, brandsResponse.error?.message || '브랜드 목록을 불러올 수 없습니다.');
	}

	return {
		brands: brandsResponse.data || [],
		totalCount: brandsResponse.data?.length || 0
	};
};
