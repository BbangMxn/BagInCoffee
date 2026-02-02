export type NotificationType =
    | 'like'
    | 'comment'
    | 'follow'
    | 'mention'
    | 'system';

export interface AppNotification {
    id: string;
    user_id: string;
    type: NotificationType;
    title: string;                       // ✅ 원래 이름 유지
    message: string;
    link: string | null;
    data: NotificationData | null;       // ✅ 원래 이름 유지
    is_read: boolean;
    created_at: string;
    read_at: string | null;
}

export interface NotificationData {
    post_id?: string;
    liker_id?: string;
    comment_id?: string;
    commenter_id?: string;
    follower_id?: string;
    mentioner_id?: string;
    action?: string;
    metadata?: Record<string, any>;
}

export interface AppNotificationWithUser extends AppNotification {
    actor?: {
        id: string;
        username: string | null;
        full_name: string | null;
        avatar_url: string | null;
    };
}

export interface CreateNotificationInput {
    user_id: string;
    type: NotificationType;
    title: string;
    message: string;
    link?: string;
    data?: NotificationData;
}