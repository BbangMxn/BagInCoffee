import type { PageServerLoad, Actions } from './$types';
import { error, fail } from '@sveltejs/kit';
import { PostRepository } from '$lib/server/database/Repository/post.repository';
import { CommentRepository } from '$lib/server/database/Repository/comment.repository';

export const load: PageServerLoad = async ({ params, locals: { supabase } }) => {
	// ✅ getUser()로 서버 검증
	const { data: { user } } = await supabase.auth.getUser();

	const postRepo = new PostRepository(supabase);
	const commentRepo = new CommentRepository(supabase);

	// Get post with author info
	const post = await postRepo.findById(params.id);
	if (!post) {
		throw error(404, 'Post not found');
	}

	// Get comments with hierarchical structure (parent comments with replies)
	const comments = await commentRepo.findByPostIdWithReplies(params.id);

	// Check if user has liked this post
	let hasLiked = false;
	if (user) {
		const { data } = await supabase
			.from('post_likes')
			.select('id')
			.eq('post_id', params.id)
			.eq('user_id', user.id)
			.single();
		hasLiked = !!data;
	}

	return {
		post: {
			...post,
			hasLiked
		},
		comments
	};
};

export const actions: Actions = {
	// Create new comment or reply
	createComment: async ({ request, params, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) {
			return fail(401, { error: 'Unauthorized' });
		}

		const formData = await request.formData();
		const content = formData.get('content') as string;
		const parentCommentId = formData.get('parent_comment_id') as string | null;

		if (!content || content.trim().length === 0) {
			return fail(400, { error: 'Comment content is required' });
		}

		if (content.length > 1000) {
			return fail(400, { error: 'Comment is too long (max 1000 characters)' });
		}

		const commentRepo = new CommentRepository(supabase);

		try {
			const comment = await commentRepo.create(
				user.id,
				params.id,
				content.trim(),
				parentCommentId
			);

			return { success: true, comment };
		} catch (err) {
			console.error('Failed to create comment:', err);
			return fail(500, { error: 'Failed to create comment' });
		}
	},

	// Update comment
	updateComment: async ({ request, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) {
			return fail(401, { error: 'Unauthorized' });
		}

		const formData = await request.formData();
		const commentId = formData.get('comment_id') as string;
		const content = formData.get('content') as string;

		if (!content || content.trim().length === 0) {
			return fail(400, { error: 'Comment content is required' });
		}

		if (content.length > 1000) {
			return fail(400, { error: 'Comment is too long (max 1000 characters)' });
		}

		const commentRepo = new CommentRepository(supabase);

		try {
			const comment = await commentRepo.update(commentId, user.id, content.trim());
			return { success: true, comment };
		} catch (err) {
			console.error('Failed to update comment:', err);
			return fail(500, { error: 'Failed to update comment' });
		}
	},

	// Delete comment
	deleteComment: async ({ request, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) {
			return fail(401, { error: 'Unauthorized' });
		}

		const formData = await request.formData();
		const commentId = formData.get('comment_id') as string;

		const commentRepo = new CommentRepository(supabase);

		try {
			const success = await commentRepo.delete(commentId, user.id);
			if (!success) {
				return fail(404, { error: 'Comment not found or unauthorized' });
			}
			return { success: true };
		} catch (err) {
			console.error('Failed to delete comment:', err);
			return fail(500, { error: 'Failed to delete comment' });
		}
	},

	// Toggle like
	toggleLike: async ({ params, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) {
			return fail(401, { error: 'Unauthorized' });
		}

		const postRepo = new PostRepository(supabase);

		try {
			const liked = await postRepo.toggleLike(params.id, user.id);
			return { success: true, liked };
		} catch (err) {
			console.error('Failed to toggle like:', err);
			return fail(500, { error: 'Failed to toggle like' });
		}
	}
};
