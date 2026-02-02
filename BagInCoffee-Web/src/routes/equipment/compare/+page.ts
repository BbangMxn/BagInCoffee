import type { PageLoad } from './$types';
import { equipmentApi, brandApi } from '$lib/api';

export const load: PageLoad = async () => {
	// 모든 장비와 브랜드 정보 조회
	const [equipmentResponse, brandsResponse] = await Promise.all([
		equipmentApi.getAll({ page: 1, page_size: 200, sort_by: 'rating' }),
		brandApi.getAll()
	]);

	return {
		equipment: equipmentResponse.success ? equipmentResponse.data : [],
		brands: brandsResponse.success ? brandsResponse.data : [],
		error:
			!equipmentResponse.success || !brandsResponse.success
				? 'Failed to load data'
				: null
	};
};
