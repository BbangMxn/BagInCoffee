import { apiClient, type ApiResponse } from './client';
import type { AppNotification } from '$lib/types/notification';

/**
 * 🔔 Notifications API
 */

export const notificationsApi = {
	/**
	 * 알림 목록 조회
	 */
	async getAll(params?: {
		page?: number;
		page_size?: number;
		unread_only?: boolean;
		type?: string;
	}): Promise<ApiResponse<AppNotification[]>> {
		return apiClient.get<AppNotification[]>('/notifications', params);
	},

	/**
	 * 읽지 않은 알림 개수 조회 (경량)
	 */
	async getUnreadCount(): Promise<ApiResponse<{ count: number }>> {
		return apiClient.get<{ count: number }>('/notifications/unread-count');
	},

	/**
	 * 모든 알림을 읽음으로 표시
	 */
	async markAllAsRead(): Promise<ApiResponse<{ message: string }>> {
		return apiClient.post('/notifications/mark-read', { all: true });
	},

	/**
	 * 특정 알림들을 읽음으로 표시
	 */
	async markAsRead(notificationIds: string[]): Promise<ApiResponse<{ message: string }>> {
		return apiClient.post('/notifications/mark-read', { notification_ids: notificationIds });
	},

	/**
	 * 읽지 않은 알림만 조회
	 */
	async getUnread(params?: { page?: number; page_size?: number }): Promise<
		ApiResponse<AppNotification[]>
	> {
		return apiClient.get<AppNotification[]>('/notifications', {
			...params,
			unread_only: true
		});
	}
};
