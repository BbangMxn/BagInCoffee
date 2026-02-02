import type { UserProfileSimple } from './user';
import type { Entity, Engageable, UserGenerated } from './common';

/**
 * 소셜 피드 게시물
 * @table posts
 * @rls Enabled
 */
export interface Post extends Entity, Engageable, UserGenerated {
	/** 게시물 내용 (필수) */
	content: string;

	/** 이미지 URL 배열 */
	images: string[];

	/** 태그 배열 */
	tags: string[] | null;
}

/**
 * 게시물 + 작성자 정보 (피드용)
 */
export interface PostWithAuthor extends Post {
	/** 작성자 프로필 */
	author: UserProfileSimple;

	/** 현재 사용자의 좋아요 여부 */
	hasLiked?: boolean;
}

/**
 * 게시물 작성 Input
 */
export interface CreatePostInput {
	/** 게시물 내용 */
	content: string;

	/** 이미지 URL 배열 */
	images?: string[];

	/** 태그 배열 */
	tags?: string[];
}
