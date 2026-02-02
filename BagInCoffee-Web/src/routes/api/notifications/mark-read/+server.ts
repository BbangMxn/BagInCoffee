import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { NotificationRepository } from '$lib/server/database/Repository/notification.repository';

/**
 * POST /api/notifications/mark-read
 * 알림을 읽음으로 표시 (단일 또는 전체)
 * Body: { notification_ids?: string[], all?: boolean }
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const body = await request.json();

	const notificationRepo = new NotificationRepository(supabase);

	try {
		if (body.all) {
			// 모든 알림 읽음 처리
			const success = await notificationRepo.markAllAsRead(userId);

			if (!success) {
				return svelteError(500, 'Failed to mark all as read');
			}

			return json({
				success: true,
				message: 'All notifications marked as read'
			});
		} else if (body.notification_ids && Array.isArray(body.notification_ids)) {
			// 여러 알림 읽음 처리
			const success = await notificationRepo.markMultipleAsRead(body.notification_ids, userId);

			if (!success) {
				return svelteError(500, 'Failed to mark notifications as read');
			}

			return json({
				success: true,
				message: 'Notifications marked as read'
			});
		} else {
			return svelteError(400, 'notification_ids or all flag is required');
		}
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
