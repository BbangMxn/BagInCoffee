/**
 * 🌐 API Index
 *
 * 모든 API 클라이언트를 한 곳에서 export
 *
 * 사용 예시:
 * ```ts
 * import { postsApi } from '$lib/api';
 *
 * const response = await postsApi.getFeed({ page: 1 });
 * if (response.success) {
 *   console.log(response.data);
 * }
 * ```
 */

export { apiClient, type ApiResponse } from './client';
export { postsApi } from './posts';
export { equipmentApi } from './equipment';
export { brandApi } from './brand';
export { recipesApi } from './recipes';
export { marketplaceApi } from './marketplace';
export { notificationsApi } from './notifications';
export { guideApi } from './guide';

// 모든 API를 하나의 객체로 export
export const api = {
	posts: postsApi,
	equipment: equipmentApi,
	brand: brandApi,
	recipes: recipesApi,
	marketplace: marketplaceApi,
	notifications: notificationsApi,
	guide: guideApi
};

// Re-export for convenience
import { postsApi } from './posts';
import { equipmentApi } from './equipment';
import { brandApi } from './brand';
import { recipesApi } from './recipes';
import { marketplaceApi } from './marketplace';
import { notificationsApi } from './notifications';
import { guideApi } from './guide';
