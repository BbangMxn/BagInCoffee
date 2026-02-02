import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { NotificationRepository } from '$lib/server/database/Repository/notification.repository';

/**
 * GET /api/notifications
 * 사용자의 알림 목록 조회
 * Query params: page, page_size, unread_only, type
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const userId = user.id;
	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '20');
	const unreadOnly = url.searchParams.get('unread_only') === 'true';
	const type = url.searchParams.get('type');

	const notificationRepo = new NotificationRepository(supabase);

	try {
		let result;

		if (type) {
			// 타입별 조회
			result = await notificationRepo.findByType(userId, type, page, pageSize);
		} else {
			// 전체 조회
			result = await notificationRepo.findByUserId(userId, page, pageSize, unreadOnly);
		}

		return json({
			success: true,
			data: result.notifications,
			pagination: {
				page,
				page_size: pageSize,
				total_count: result.count,
				total_pages: Math.ceil(result.count / pageSize)
			}
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * POST /api/notifications
 * 알림 생성 (시스템용)
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	// TODO: 관리자 권한 체크 (시스템 알림은 관리자만 생성 가능)

	const body = await request.json();

	// 유효성 검사
	if (!body.user_id || !body.type || !body.title || !body.message) {
		return svelteError(400, 'Required fields are missing');
	}

	const notificationRepo = new NotificationRepository(supabase);

	try {
		const notification = await notificationRepo.create(body);

		return json({
			success: true,
			data: notification
		}, { status: 201 });
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
