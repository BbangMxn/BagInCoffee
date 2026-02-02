import type { SupabaseClient } from '@supabase/supabase-js';
import type { Like } from '$lib/types/like';

/**
 * 💗 LikeRepository
 *
 * 게시물 좋아요 관리
 * - 좋아요 추가/제거
 * - 중복 방지
 * - 게시물의 likes_count 자동 업데이트
 */
export class LikeRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 좋아요 추가
	 * @returns 생성된 좋아요 정보, 이미 존재하면 null
	 */
	async addLike(userId: string, postId: string): Promise<Like | null> {
		// 중복 체크
		const { data: existing } = await this.supabase
			.from('likes')
			.select('id')
			.eq('user_id', userId)
			.eq('post_id', postId)
			.single();

		if (existing) {
			return null; // 이미 좋아요한 상태
		}

		// 좋아요 추가
		const { data, error } = await this.supabase
			.from('likes')
			.insert({
				user_id: userId,
				post_id: postId
			})
			.select()
			.single();

		if (error) throw error;

		// 게시물의 likes_count 증가
		await this.incrementPostLikesCount(postId);

		return data as Like;
	}

	/**
	 * 좋아요 제거
	 * @returns 성공 여부
	 */
	async removeLike(userId: string, postId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('likes')
			.delete()
			.eq('user_id', userId)
			.eq('post_id', postId);

		if (!error) {
			// 게시물의 likes_count 감소
			await this.decrementPostLikesCount(postId);
		}

		return !error;
	}

	/**
	 * 사용자가 특정 게시물에 좋아요를 눌렀는지 확인
	 */
	async hasLiked(userId: string, postId: string): Promise<boolean> {
		const { data } = await this.supabase
			.from('likes')
			.select('id')
			.eq('user_id', userId)
			.eq('post_id', postId)
			.single();

		return !!data;
	}

	/**
	 * 사용자가 좋아요한 게시물 ID 목록 조회 (bulk)
	 * @param postIds 확인할 게시물 ID 배열
	 * @returns 좋아요한 게시물 ID Set
	 */
	async getLikedPostIds(userId: string, postIds: string[]): Promise<Set<string>> {
		if (postIds.length === 0) return new Set();

		const { data, error } = await this.supabase
			.from('likes')
			.select('post_id')
			.eq('user_id', userId)
			.in('post_id', postIds);

		if (error || !data) return new Set();

		return new Set(data.map((like) => like.post_id));
	}

	/**
	 * 게시물의 좋아요 수 조회
	 */
	async getPostLikesCount(postId: string): Promise<number> {
		const { count, error } = await this.supabase
			.from('likes')
			.select('*', { count: 'exact', head: true })
			.eq('post_id', postId);

		if (error) return 0;
		return count ?? 0;
	}

	/**
	 * 게시물에 좋아요한 사용자 목록 조회 (페이지네이션)
	 */
	async getUsersWhoLiked(
		postId: string,
		page = 1,
		pageSize = 20
	): Promise<{ users: any[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('likes')
			.select(
				`
				created_at,
				user:profiles!user_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.eq('post_id', postId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { users: [], count: 0 };
		}

		return { users: data, count: count ?? 0 };
	}

	/**
	 * 사용자가 좋아요한 게시물 목록 조회
	 */
	async getUserLikedPosts(
		userId: string,
		page = 1,
		pageSize = 20
	): Promise<{ posts: any[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('likes')
			.select(
				`
				created_at,
				post:posts!post_id (
					id,
					user_id,
					content,
					image_url,
					likes_count,
					comments_count,
					tags,
					created_at,
					updated_at,
					author:profiles!user_id (
						id,
						username,
						full_name,
						avatar_url
					)
				)
			`,
				{ count: 'exact' }
			)
			.eq('user_id', userId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { posts: [], count: 0 };
		}

		return { posts: data, count: count ?? 0 };
	}

	/**
	 * 게시물의 likes_count 증가 (내부 함수)
	 */
	private async incrementPostLikesCount(postId: string): Promise<void> {
		await this.supabase.rpc('increment_post_likes', { post_id: postId });
	}

	/**
	 * 게시물의 likes_count 감소 (내부 함수)
	 */
	private async decrementPostLikesCount(postId: string): Promise<void> {
		await this.supabase.rpc('decrement_post_likes', { post_id: postId });
	}

	/**
	 * 좋아요 토글 (있으면 제거, 없으면 추가)
	 * @returns { added: boolean, like?: Like }
	 */
	async toggleLike(userId: string, postId: string): Promise<{ added: boolean; like?: Like }> {
		const hasLiked = await this.hasLiked(userId, postId);

		if (hasLiked) {
			await this.removeLike(userId, postId);
			return { added: false };
		} else {
			const like = await this.addLike(userId, postId);
			return { added: true, like: like ?? undefined };
		}
	}
}
