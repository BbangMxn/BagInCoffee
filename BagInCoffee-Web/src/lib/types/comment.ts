import type { UserProfileSimple } from './user';
import type { Entity, UserGenerated } from './common';

/**
 * 댓글 인터페이스
 * @table comments
 * @rls Enabled
 */
export interface Comment extends Entity, UserGenerated {
	/** 게시물 ID (posts.id 참조) */
	post_id: string;

	/** 부모 댓글 ID (null이면 일반 댓글, 값이 있으면 대댓글) */
	parent_comment_id: string | null;

	/** 댓글 내용 */
	content: string;

	/** 대댓글 개수 */
	replies_count: number;

	/** 작성자 프로필 정보 (JOIN 시 포함) */
	profiles?: UserProfileSimple;

	/** 대댓글 배열 (계층 구조 조회 시 포함) */
	replies?: Comment[];
}

/**
 * 댓글 작성 Input
 */
export interface CreateCommentInput {
	/** 게시물 ID */
	post_id: string;

	/** 댓글 내용 */
	content: string;

	/** 부모 댓글 ID (대댓글인 경우만) */
	parent_comment_id?: string | null;
}
