import type { SupabaseClient } from '@supabase/supabase-js';
import type { Comment, CreateCommentInput } from '$lib/types/comment';

/**
 * 게시물의 모든 댓글 조회 (대댓글 포함)
 *
 * 계층 구조:
 * 1. 일반 댓글만 조회 (parent_comment_id IS NULL)
 * 2. 각 댓글의 대댓글을 별도로 조회
 * 3. 댓글에 대댓글을 포함하여 반환
 */
export async function getCommentsWithReplies(
	supabase: SupabaseClient,
	postId: string
): Promise<{ success: boolean; comments?: Comment[]; error?: string }> {
	try {
		// 1. 일반 댓글 조회 (부모 댓글만)
		const { data: parentComments, error: parentError } = await supabase
			.from('comments')
			.select(
				`
        *,
        profiles:user_id (
          id,
          username,
          full_name,
          avatar_url
        )
      `
			)
			.eq('post_id', postId)
			.is('parent_comment_id', null)
			.order('created_at', { ascending: false });

		if (parentError) throw parentError;

		// 2. 각 댓글의 대댓글 조회
		const commentsWithReplies = await Promise.all(
			(parentComments || []).map(async (comment) => {
				const { data: replies, error: repliesError } = await supabase
					.from('comments')
					.select(
						`
            *,
            profiles:user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          `
					)
					.eq('parent_comment_id', comment.id)
					.order('created_at', { ascending: true }); // 대댓글은 시간순

				if (repliesError) {
					console.error('대댓글 조회 에러:', repliesError);
					return { ...comment, replies: [] };
				}

				return { ...comment, replies: replies || [] };
			})
		);

		return { success: true, comments: commentsWithReplies };
	} catch (err) {
		console.error('댓글 조회 에러:', err);
		return {
			success: false,
			error: '댓글을 불러오는 중 오류가 발생했습니다.'
		};
	}
}

/**
 * 댓글 작성 (일반 댓글 또는 대댓글)
 */
export async function createComment(
	supabase: SupabaseClient,
	input: CreateCommentInput
): Promise<{ success: boolean; comment?: Comment; error?: string }> {
	try {
		const { data, error } = await supabase
			.from('comments')
			.insert({
				post_id: input.post_id,
				content: input.content,
				parent_comment_id: input.parent_comment_id || null
			})
			.select(
				`
        *,
        profiles:user_id (
          id,
          username,
          full_name,
          avatar_url
        )
      `
			)
			.single();

		if (error) throw error;

		// posts 테이블의 comments_count 증가
		await supabase.rpc('increment_post_comments_count', { post_id: input.post_id });

		return { success: true, comment: data };
	} catch (err) {
		console.error('댓글 작성 에러:', err);
		return { success: false, error: '댓글 작성 중 오류가 발생했습니다.' };
	}
}

/**
 * 댓글 삭제
 */
export async function deleteComment(
	supabase: SupabaseClient,
	commentId: string,
	postId: string
): Promise<{ success: boolean; error?: string }> {
	try {
		const { error } = await supabase.from('comments').delete().eq('id', commentId);

		if (error) throw error;

		// posts 테이블의 comments_count 감소
		await supabase.rpc('decrement_post_comments_count', { post_id: postId });

		return { success: true };
	} catch (err) {
		console.error('댓글 삭제 에러:', err);
		return { success: false, error: '댓글 삭제 중 오류가 발생했습니다.' };
	}
}

/**
 * 댓글 수정
 */
export async function updateComment(
	supabase: SupabaseClient,
	commentId: string,
	content: string
): Promise<{ success: boolean; error?: string }> {
	try {
		const { error } = await supabase
			.from('comments')
			.update({ content, updated_at: new Date().toISOString() })
			.eq('id', commentId);

		if (error) throw error;

		return { success: true };
	} catch (err) {
		console.error('댓글 수정 에러:', err);
		return { success: false, error: '댓글 수정 중 오류가 발생했습니다.' };
	}
}
