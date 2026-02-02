import type { PageLoad } from './$types';
import { equipmentApi } from '$lib/api';

export const load: PageLoad = async () => {
	// 추출 도구 카테고리로 필터링하여 조회
	const response = await equipmentApi.getAll({
		category_id: 'brewing-tools', // 실제 DB의 카테고리 ID로 변경 필요
		page: 1,
		page_size: 50,
		sort_by: 'rating'
	});

	return {
		tools: response.success ? response.data : [],
		error: response.success ? null : response.error?.message
	};
};
