import { apiClient, type ApiResponse } from './client';
import type { Post, PostWithAuthor, CreatePostInput } from '$lib/types/Post';

/**
 * 📱 Posts API
 */

export const postsApi = {
	/**
	 * 게시물 피드 조회
	 */
	async getFeed(params?: {
		page?: number;
		page_size?: number;
		tag?: string;
		user_id?: string;
	}): Promise<ApiResponse<PostWithAuthor[]>> {
		return apiClient.get<PostWithAuthor[]>('/posts', params);
	},

	/**
	 * 특정 게시물 조회
	 */
	async getById(id: string): Promise<ApiResponse<PostWithAuthor>> {
		return apiClient.get<PostWithAuthor>(`/posts/${id}`);
	},

	/**
	 * 게시물 작성
	 */
	async create(input: CreatePostInput): Promise<ApiResponse<Post>> {
		return apiClient.post<Post>('/posts', input);
	},

	/**
	 * 게시물 수정
	 */
	async update(id: string, updates: Partial<CreatePostInput>): Promise<ApiResponse<Post>> {
		return apiClient.patch<Post>(`/posts/${id}`, updates);
	},

	/**
	 * 게시물 삭제
	 */
	async delete(id: string): Promise<ApiResponse<{ message: string }>> {
		return apiClient.delete(`/posts/${id}`);
	},

	/**
	 * 좋아요 토글
	 */
	async toggleLike(postId: string): Promise<
		ApiResponse<{
			liked: boolean;
			like?: any;
		}>
	> {
		return apiClient.post(`/posts/${postId}/like`);
	},

	/**
	 * 댓글 목록 조회
	 */
	async getComments(
		postId: string,
		params?: { page?: number; page_size?: number }
	): Promise<ApiResponse<any[]>> {
		return apiClient.get(`/posts/${postId}/comments`, params);
	},

	/**
	 * 댓글 작성
	 */
	async createComment(postId: string, content: string): Promise<ApiResponse<any>> {
		return apiClient.post(`/posts/${postId}/comments`, { content });
	}
};
