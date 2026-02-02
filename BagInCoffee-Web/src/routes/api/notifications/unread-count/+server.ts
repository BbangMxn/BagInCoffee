import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { NotificationRepository } from '$lib/server/database/Repository/notification.repository';

/**
 * GET /api/notifications/unread-count
 * 읽지 않은 알림 개수 조회 (경량 쿼리)
 */
export const GET: RequestHandler = async ({ locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const notificationRepo = new NotificationRepository(supabase);

	try {
		const count = await notificationRepo.countUnread(userId);

		return json({
			success: true,
			data: { count }
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
