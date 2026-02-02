import type { SupabaseClient } from '@supabase/supabase-js';
import type { Comment } from '$lib/types/comment';

/**
 * 댓글 Repository
 *
 * 대댓글 지원 기능:
 * - parent_comment_id를 통한 계층 구조
 * - 일반 댓글과 대댓글 구분
 * - 대댓글 개수 자동 계산
 */
export class CommentRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 댓글 ID로 조회 (작성자 정보 포함)
	 *
	 * @param commentId - 댓글 ID
	 * @returns 댓글 정보 (작성자 포함)
	 */
	async findById(commentId: string): Promise<Comment | null> {
		const { data, error } = await this.supabase
			.from('comments')
			.select(
				`
				*,
				profiles:user_id (
					username,
					full_name,
					avatar_url
				)
			`
			)
			.eq('id', commentId)
			.single();

		if (error || !data) return null;

		return data as Comment;
	}

	/**
	 * 게시물의 모든 댓글 조회 (계층 구조)
	 *
	 * 1. 부모 댓글만 조회 (parent_comment_id IS NULL)
	 * 2. 각 부모 댓글의 대댓글을 별도 조회
	 * 3. replies 배열에 포함하여 반환
	 *
	 * @param postId - 게시물 ID
	 * @returns 댓글 배열 (대댓글 포함)
	 */
	async findByPostIdWithReplies(postId: string): Promise<Comment[]> {
		// 1. 부모 댓글 조회
		const { data: parentComments, error: parentError } = await this.supabase
			.from('comments')
			.select(
				`
				*,
				profiles:user_id (
					username,
					full_name,
					avatar_url
				)
			`
			)
			.eq('post_id', postId)
			.is('parent_comment_id', null)
			.order('created_at', { ascending: false });

		if (parentError || !parentComments) {
			return [];
		}

		// 2. 각 부모 댓글의 대댓글 조회
		const commentsWithReplies = await Promise.all(
			parentComments.map(async (comment) => {
				const { data: replies } = await this.supabase
					.from('comments')
					.select(
						`
						*,
						profiles:user_id (
							username,
							full_name,
							avatar_url
						)
					`
					)
					.eq('parent_comment_id', comment.id)
					.order('created_at', { ascending: true });

				return {
					...comment,
					replies: replies || []
				} as Comment;
			})
		);

		return commentsWithReplies;
	}

	/**
	 * 게시물의 댓글 조회 (평면 구조, 페이지네이션)
	 *
	 * @param postId - 게시물 ID
	 * @param page - 페이지 번호
	 * @param pageSize - 페이지 크기
	 * @returns 댓글 배열 및 총 개수
	 */
	async findByPostId(
		postId: string,
		page = 1,
		pageSize = 20
	): Promise<{ comments: Comment[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('comments')
			.select(
				`
				*,
				profiles:user_id (
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.eq('post_id', postId)
			.order('created_at', { ascending: true })
			.range(from, to);

		if (error || !data) {
			return { comments: [], count: 0 };
		}

		return { comments: data as Comment[], count: count ?? 0 };
	}

	/**
	 * 특정 댓글의 대댓글 조회
	 *
	 * @param parentCommentId - 부모 댓글 ID
	 * @returns 대댓글 배열
	 */
	async findReplies(parentCommentId: string): Promise<Comment[]> {
		const { data, error } = await this.supabase
			.from('comments')
			.select(
				`
				*,
				profiles:user_id (
					username,
					full_name,
					avatar_url
				)
			`
			)
			.eq('parent_comment_id', parentCommentId)
			.order('created_at', { ascending: true });

		if (error || !data) {
			return [];
		}

		return data as Comment[];
	}

	/**
	 * 특정 사용자의 댓글 조회
	 *
	 * @param userId - 사용자 ID
	 * @param page - 페이지 번호
	 * @param pageSize - 페이지 크기
	 * @returns 댓글 배열 및 총 개수
	 */
	async findByUserId(
		userId: string,
		page = 1,
		pageSize = 20
	): Promise<{ comments: Comment[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('comments')
			.select('*', { count: 'exact' })
			.eq('user_id', userId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { comments: [], count: 0 };
		}

		return { comments: data as Comment[], count: count ?? 0 };
	}

	/**
	 * 댓글 생성 (일반 댓글 또는 대댓글)
	 *
	 * @param userId - 작성자 ID
	 * @param postId - 게시물 ID
	 * @param content - 댓글 내용
	 * @param parentCommentId - 부모 댓글 ID (대댓글인 경우)
	 * @returns 생성된 댓글
	 */
	async create(
		userId: string,
		postId: string,
		content: string,
		parentCommentId?: string | null
	): Promise<Comment> {
		const { data, error } = await this.supabase
			.from('comments')
			.insert({
				user_id: userId,
				post_id: postId,
				content,
				parent_comment_id: parentCommentId || null
			})
			.select(
				`
				*,
				profiles:user_id (
					username,
					full_name,
					avatar_url
				)
			`
			)
			.single();

		if (error) throw error;

		// 부모 댓글의 replies_count 증가 (대댓글인 경우)
		if (parentCommentId) {
			await this.incrementRepliesCount(parentCommentId);
		}

		return data as Comment;
	}

	/**
	 * 댓글 수정
	 *
	 * @param commentId - 댓글 ID
	 * @param userId - 작성자 ID (권한 확인용)
	 * @param content - 새로운 내용
	 * @returns 수정된 댓글
	 */
	async update(commentId: string, userId: string, content: string): Promise<Comment> {
		const { data, error } = await this.supabase
			.from('comments')
			.update({
				content,
				updated_at: new Date().toISOString()
			})
			.eq('id', commentId)
			.eq('user_id', userId) // 작성자만 수정 가능
			.select(
				`
				*,
				profiles:user_id (
					username,
					full_name,
					avatar_url
				)
			`
			)
			.single();

		if (error) throw error;
		return data as Comment;
	}

	/**
	 * 댓글 삭제
	 *
	 * @param commentId - 댓글 ID
	 * @param userId - 작성자 ID (권한 확인용)
	 * @returns 성공 여부
	 */
	async delete(commentId: string, userId: string): Promise<boolean> {
		// 댓글 정보 조회 (parent_comment_id 확인용)
		const comment = await this.findById(commentId);
		if (!comment) return false;

		// 삭제
		const { error } = await this.supabase
			.from('comments')
			.delete()
			.eq('id', commentId)
			.eq('user_id', userId); // 작성자만 삭제 가능

		if (error) return false;

		// 부모 댓글의 replies_count 감소 (대댓글인 경우)
		if (comment.parent_comment_id) {
			await this.decrementRepliesCount(comment.parent_comment_id);
		}

		return true;
	}

	/**
	 * 게시물의 댓글 수 조회
	 *
	 * @param postId - 게시물 ID
	 * @returns 댓글 개수
	 */
	async countByPostId(postId: string): Promise<number> {
		const { count, error } = await this.supabase
			.from('comments')
			.select('*', { count: 'exact', head: true })
			.eq('post_id', postId);

		if (error) return 0;
		return count ?? 0;
	}

	/**
	 * 부모 댓글의 대댓글 개수 증가
	 *
	 * NOTE: DB 트리거 update_comment_replies_count()가
	 * INSERT 시 자동으로 처리하지만, 안전을 위해 수동 호출 유지
	 *
	 * @param parentCommentId - 부모 댓글 ID
	 */
	private async incrementRepliesCount(parentCommentId: string): Promise<void> {
		// 트리거가 있지만 수동으로도 증가 (이중 안전장치)
		try {
			await this.supabase.rpc('increment_comment_replies_count', {
				comment_id: parentCommentId
			});
		} catch (error) {
			// RPC 함수가 없는 경우 현재 값을 가져와서 업데이트
			const { data } = await this.supabase
				.from('comments')
				.select('replies_count')
				.eq('id', parentCommentId)
				.single();

			if (data) {
				await this.supabase
					.from('comments')
					.update({
						replies_count: (data.replies_count || 0) + 1
					})
					.eq('id', parentCommentId);
			}
		}
	}

	/**
	 * 부모 댓글의 대댓글 개수 감소
	 *
	 * NOTE: DB 트리거 update_comment_replies_count()가
	 * DELETE 시 자동으로 처리하지만, 안전을 위해 수동 호출 유지
	 *
	 * @param parentCommentId - 부모 댓글 ID
	 */
	private async decrementRepliesCount(parentCommentId: string): Promise<void> {
		// 트리거가 있지만 수동으로도 감소 (이중 안전장치)
		try {
			await this.supabase.rpc('decrement_comment_replies_count', {
				comment_id: parentCommentId
			});
		} catch (error) {
			// RPC 함수가 없는 경우 현재 값을 가져와서 업데이트
			const { data } = await this.supabase
				.from('comments')
				.select('replies_count')
				.eq('id', parentCommentId)
				.single();

			if (data) {
				await this.supabase
					.from('comments')
					.update({
						replies_count: Math.max((data.replies_count || 0) - 1, 0)
					})
					.eq('id', parentCommentId);
			}
		}
	}
}
