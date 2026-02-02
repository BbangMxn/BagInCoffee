// src/lib/types/activity.ts

export interface Activity {
    id: string;
    user_id: string;
    type: ActivityType;
    target_id: string;
    target_type: 'post' | 'comment' | 'user' | 'equipment';
    metadata?: Record<string, any>;
    created_at: string;
}

export type ActivityType =
    | 'post_created'
    | 'comment_added'
    | 'liked'
    | 'followed'
    | 'reviewed';