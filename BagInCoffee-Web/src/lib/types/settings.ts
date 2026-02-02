// src/lib/types/settings.ts

export interface UserSettings {
    user_id: string;

    // 프라이버시
    profile_visibility: 'public' | 'private';
    show_email: boolean;

    // 알림
    notification_settings: NotificationSettings;

    // 언어 및 테마
    language: 'ko' | 'en';
    theme: 'light' | 'dark' | 'auto';

    updated_at: string;
}

// notification.ts에 추가
export interface NotificationSettings {
    enable_like: boolean;
    enable_comment: boolean;
    enable_follow: boolean;
    enable_mention: boolean;
    enable_system: boolean;
    enable_email: boolean;
    enable_push: boolean;
}