/**
 * 💗 좋아요 시스템
 *
 * DB 스키마:
 * - id: uuid (PK, default: uuid_generate_v4())
 * - user_id: uuid (FK → auth.users.id)
 * - post_id: uuid (FK → posts.id)
 * - created_at: timestamptz (default: now())
 *
 * 제약사항:
 * - 한 사용자가 한 게시물에 한 번만 좋아요 가능
 * - RLS 활성화
 */

export interface Like {
	id: string;
	user_id: string;
	post_id: string;
	created_at: string;
}

/**
 * 좋아요 생성 요청
 */
export interface CreateLikeRequest {
	post_id: string;
}
