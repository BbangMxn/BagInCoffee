import type { SupabaseClient } from '@supabase/supabase-js';
import type { Post, PostWithAuthor, CreatePostInput } from '$lib/types/Post';
import type { UserProfileSimple } from '$lib/types/user';

export class PostRepository {
	constructor(private supabase: SupabaseClient) {}

	/**
	 * 게시물 ID로 조회 (작성자 정보 포함)
	 */
	async findById(postId: string, currentUserId?: string): Promise<PostWithAuthor | null> {
		const { data, error } = await this.supabase
			.from('posts')
			.select(
				`
				id,
				user_id,
				content,
				images,
				likes_count,
				comments_count,
				tags,
				created_at,
				updated_at,
				profiles!user_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`
			)
			.eq('id', postId)
			.single();

		if (error || !data) return null;

		// hasLiked 확인 (현재 사용자가 좋아요 했는지)
		let hasLiked = false;
		if (currentUserId) {
			const { data: likeData } = await this.supabase
				.from('likes')
				.select('id')
				.eq('post_id', postId)
				.eq('user_id', currentUserId)
				.single();

			hasLiked = !!likeData;
		}

		// profiles는 배열로 반환되므로 첫 번째 요소를 가져옴
		const profiles = Array.isArray(data.profiles) ? data.profiles[0] : data.profiles;

		return {
			...data,
			author: profiles as UserProfileSimple,
			hasLiked
		};
	}

	/**
	 * 피드 조회 (페이지네이션, 작성자 정보 포함)
	 * 최신순 정렬
	 */
	async findFeed(
		page = 1,
		pageSize = 20,
		currentUserId?: string
	): Promise<{ posts: PostWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		// 게시물 조회
		const { data, error, count } = await this.supabase
			.from('posts')
			.select(
				`
				id,
				user_id,
				content,
				images,
				likes_count,
				comments_count,
				tags,
				created_at,
				updated_at,
				profiles:user_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { posts: [], count: 0 };
		}

		// hasLiked 확인 (bulk)
		let likedPostIds: Set<string> = new Set();
		if (currentUserId && data.length > 0) {
			const postIds = data.map((p) => p.id);
			const { data: likesData } = await this.supabase
				.from('likes')
				.select('post_id')
				.eq('user_id', currentUserId)
				.in('post_id', postIds);

			if (likesData) {
				likedPostIds = new Set(likesData.map((l) => l.post_id));
			}
		}

		const posts = data.map((post) => {
			const profiles = Array.isArray(post.profiles) ? post.profiles[0] : post.profiles;
			return {
				...post,
				author: profiles as UserProfileSimple,
				hasLiked: likedPostIds.has(post.id)
			};
		});

		return { posts, count: count ?? 0 };
	}

	/**
	 * 특정 사용자의 게시물 조회
	 */
	async findByUserId(
		userId: string,
		page = 1,
		pageSize = 20
	): Promise<{ posts: Post[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('posts')
			.select('*', { count: 'exact' })
			.eq('user_id', userId)
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { posts: [], count: 0 };
		}

		return { posts: data as Post[], count: count ?? 0 };
	}

	/**
	 * 게시물 생성
	 */
	async create(userId: string, input: CreatePostInput): Promise<Post> {
		const { data, error } = await this.supabase
			.from('posts')
			.insert({
				user_id: userId,
				content: input.content,
				images: input.images ?? null,
				tags: input.tags ?? null,
				likes_count: 0,
				comments_count: 0
			})
			.select()
			.single();

		if (error) throw error;
		return data as Post;
	}

	/**
	 * 게시물 수정
	 */
	async update(
		postId: string,
		userId: string,
		updates: Partial<CreatePostInput>
	): Promise<Post> {
		const { data, error } = await this.supabase
			.from('posts')
			.update({
				...updates,
				updated_at: new Date().toISOString()
			})
			.eq('id', postId)
			.eq('user_id', userId) // 작성자만 수정 가능
			.select()
			.single();

		if (error) throw error;
		return data as Post;
	}

	/**
	 * 게시물 삭제
	 */
	async delete(postId: string, userId: string): Promise<boolean> {
		const { error } = await this.supabase
			.from('posts')
			.delete()
			.eq('id', postId)
			.eq('user_id', userId); // 작성자만 삭제 가능

		return !error;
	}

	/**
	 * 태그로 검색
	 */
	async findByTag(
		tag: string,
		page = 1,
		pageSize = 20
	): Promise<{ posts: PostWithAuthor[]; count: number }> {
		const from = (page - 1) * pageSize;
		const to = from + pageSize - 1;

		const { data, error, count } = await this.supabase
			.from('posts')
			.select(
				`
				id,
				user_id,
				content,
				images,
				likes_count,
				comments_count,
				tags,
				created_at,
				updated_at,
				profiles:user_id (
					id,
					username,
					full_name,
					avatar_url
				)
			`,
				{ count: 'exact' }
			)
			.contains('tags', [tag])
			.order('created_at', { ascending: false })
			.range(from, to);

		if (error || !data) {
			return { posts: [], count: 0 };
		}

		const posts = data.map((post) => {
			const profiles = Array.isArray(post.profiles) ? post.profiles[0] : post.profiles;
			return {
				...post,
				author: profiles as UserProfileSimple,
				hasLiked: false
			};
		});

		return { posts, count: count ?? 0 };
	}

	/**
	 * 좋아요 수 증가
	 */
	async incrementLikes(postId: string): Promise<void> {
		await this.supabase.rpc('increment_post_likes', { post_id: postId });
	}

	/**
	 * 좋아요 수 감소
	 */
	async decrementLikes(postId: string): Promise<void> {
		await this.supabase.rpc('decrement_post_likes', { post_id: postId });
	}

	/**
	 * 댓글 수 증가
	 */
	async incrementComments(postId: string): Promise<void> {
		await this.supabase.rpc('increment_post_comments', { post_id: postId });
	}

	/**
	 * 댓글 수 감소
	 */
	async decrementComments(postId: string): Promise<void> {
		await this.supabase.rpc('decrement_post_comments', { post_id: postId });
	}

	/**
	 * 좋아요 토글 (좋아요/취소)
	 * @returns true if liked, false if unliked
	 */
	async toggleLike(postId: string, userId: string): Promise<boolean> {
		// 현재 좋아요 상태 확인
		const { data: existingLike } = await this.supabase
			.from('likes')
			.select('id')
			.eq('post_id', postId)
			.eq('user_id', userId)
			.single();

		if (existingLike) {
			// 좋아요 취소
			await this.supabase
				.from('likes')
				.delete()
				.eq('post_id', postId)
				.eq('user_id', userId);

			await this.decrementLikes(postId);
			return false;
		} else {
			// 좋아요 추가
			await this.supabase
				.from('likes')
				.insert({
					post_id: postId,
					user_id: userId
				});

			await this.incrementLikes(postId);
			return true;
		}
	}
}
