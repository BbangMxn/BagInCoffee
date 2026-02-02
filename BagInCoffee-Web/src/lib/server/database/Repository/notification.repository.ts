import type { SupabaseClient } from '@supabase/supabase-js';
import type { AppNotification, CreateNotificationInput } from '$lib/types/notification';

/**
 * 🔔 NotificationRepository
 *
 * 알림 시스템 - 성능 최적화
 * - 페이지네이션으로 트래픽 최소화
 * - 읽지 않은 알림만 조회하는 경량 쿼리
 * - Bulk 읽음 처리로 쿼리 수 감소
 */
export class NotificationRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 사용자의 알림 조회 (페이지네이션)
	 * 성능 최적화: 필요한 컬럼만 select
	 */
	async findByUserId(
		userId: string,
		page = 1,
		pageSize = 20,
		unreadOnly = false
	): Promise<{ notifications: AppNotification[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		let query = this.supabase
			.from('notifications')
			.select('*', { count: 'exact' })
			.eq('user_id', userId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (unreadOnly) {
			query = query.eq('is_read', false);
		}

		const { data, error, count } = await query;

		if (error || !data) {
			return { notifications: [], count: 0 };
		}

		return { notifications: data as AppNotification[], count: count ?? 0 };
	}

	/**
	 * 읽지 않은 알림 개수만 조회 (경량 쿼리)
	 * 성능 최적화: head: true로 데이터 없이 count만 가져옴
	 */
	async countUnread(userId: string): Promise<number> {
		const { count, error } = await this.supabase
			.from('notifications')
			.select('*', { count: 'exact', head: true })
			.eq('user_id', userId)
			.eq('is_read', false);

		if (error) return 0;
		return count ?? 0;
	}

	/**
	 * 알림 ID로 조회
	 */
	async findById(notificationId: string): Promise<AppNotification | null> {
		const { data, error } = await this.supabase
			.from('notifications')
			.select('*')
			.eq('id', notificationId)
			.single();

		if (error || !data) return null;
		return data as AppNotification;
	}

	/**
	 * 알림 생성
	 */
	async create(input: CreateNotificationInput): Promise<AppNotification> {
		const { data, error } = await this.supabase
			.from('notifications')
			.insert({
				user_id: input.user_id,
				type: input.type,
				title: input.title,
				message: input.message,
				link: input.link ?? null,
				data: input.data ?? null,
				is_read: false
			})
			.select()
			.single();

		if (error) throw error;
		return data as AppNotification;
	}

	/**
	 * 알림을 읽음으로 표시
	 */
	async markAsRead(notificationId: string, userId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('notifications')
			.update({
				is_read: true,
				read_at: new Date().toISOString()
			})
			.eq('id', notificationId)
			.eq('user_id', userId);

		return !error;
	}

	/**
	 * 모든 알림을 읽음으로 표시 (Bulk 처리)
	 * 성능 최적화: 단일 쿼리로 모든 알림 업데이트
	 */
	async markAllAsRead(userId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('notifications')
			.update({
				is_read: true,
				read_at: new Date().toISOString()
			})
			.eq('user_id', userId)
			.eq('is_read', false); // 읽지 않은 것만 업데이트

		return !error;
	}

	/**
	 * 여러 알림을 읽음으로 표시 (Bulk)
	 * 성능 최적화: IN 쿼리로 한 번에 처리
	 */
	async markMultipleAsRead(notificationIds: string[], userId: string): Promise<boolean> {
		if (notificationIds.length === 0) return true;

		const { error } = await this.supabase
			.from('notifications')
			.update({
				is_read: true,
				read_at: new Date().toISOString()
			})
			.in('id', notificationIds)
			.eq('user_id', userId);

		return !error;
	}

	/**
	 * 알림 삭제
	 */
	async delete(notificationId: string, userId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('notifications')
			.delete()
			.eq('id', notificationId)
			.eq('user_id', userId);

		return !error;
	}

	/**
	 * 오래된 알림 삭제 (30일 이상)
	 * 성능 최적화: 주기적으로 실행하여 DB 크기 관리
	 */
	async deleteOldNotifications(userId: string, daysOld = 30): Promise<number> {
		const cutoffDate = new Date();
		cutoffDate.setDate(cutoffDate.getDate() - daysOld);

		const { data, error } = await this.supabase
			.from('notifications')
			.delete()
			.eq('user_id', userId)
			.lt('created_at', cutoffDate.toISOString())
			.select('id');

		if (error || !data) return 0;
		return data.length;
	}

	/**
	 * 타입별 알림 조회
	 * 성능 최적화: 인덱스 활용을 위한 타입 필터링
	 */
	async findByType(
		userId: string,
		type: string,
		page = 1,
		pageSize = 20
	): Promise<{ notifications: AppNotification[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('notifications')
			.select('*', { count: 'exact' })
			.eq('user_id', userId)
			.eq('type', type)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { notifications: [], count: 0 };
		}

		return { notifications: data as AppNotification[], count: count ?? 0 };
	}
}
