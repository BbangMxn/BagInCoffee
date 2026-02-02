// src/lib/types/report.ts

export interface Report {
    id: string;
    reporter_id: string;
    reported_user_id?: string;
    reported_post_id?: string;
    reported_comment_id?: string;
    reason: ReportReason;
    description: string | null;
    status: 'pending' | 'reviewed' | 'resolved' | 'dismissed';
    created_at: string;
}

export type ReportReason =
    | 'spam'
    | 'harassment'
    | 'inappropriate'
    | 'copyright'
    | 'misleading'
    | 'other';