<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { browser } from '$app/environment';
	import ImageGrid from '$lib/components/feed/ImageGrid.svelte';
	import { postsApi } from '$lib/api';
	import type { PostWithAuthor } from '$lib/types/Post';
	import type { LayoutData } from './$types';

	let { data } = $props<{ data: LayoutData }>();

	let showSplash = $state(false);
	let posts: PostWithAuthor[] = $state([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

	// 로그인 상태 확인
	let isLoggedIn = $derived(!!data.session);

	async function loadPosts() {
		loading = true;
		error = null;

		const response = await postsApi.getFeed({ page: 1, page_size: 20 });

		if (response.success && response.data) {
			posts = response.data;
		} else {
			error = response.error?.message || 'Failed to load posts';
		}

		loading = false;
	}

	async function toggleLike(postId: string) {
		const response = await postsApi.toggleLike(postId);

		if (response.success && response.data) {
			// UI 업데이트
			posts = posts.map((post) => {
				if (post.id === postId) {
					return {
						...post,
						hasLiked: response.data!.liked,
						likes_count: post.likes_count + (response.data!.liked ? 1 : -1)
					};
				}
				return post;
			});
		}
	}

	function getTimeAgo(dateString: string): string {
		const date = new Date(dateString);
		const now = new Date();
		const diff = Math.floor((now.getTime() - date.getTime()) / 1000);

		if (diff < 60) return '방금 전';
		if (diff < 3600) return `${Math.floor(diff / 60)}분 전`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}시간 전`;
		if (diff < 604800) return `${Math.floor(diff / 86400)}일 전`;
		return date.toLocaleDateString('ko-KR');
	}

	function getInitial(name: string | null): string {
		if (!name) return '?';
		return name.charAt(0);
	}

	onMount(() => {
		// Check if user has visited before
		const hasVisited = browser && localStorage.getItem('hasVisited');

		if (!hasVisited) {
			// First visit - show splash
			showSplash = true;

			// Mark as visited
			if (browser) {
				localStorage.setItem('hasVisited', 'true');
			}

			// Go to splash page
			goto('/splash');
		}

		// 피드는 로그인 여부와 상관없이 로드
		loadPosts();
	});
</script>

<!-- 메인 피드 (로그인 여부와 상관없이 표시) -->
<div class="max-w-2xl mx-auto px-4 py-4 relative">
	<!-- Floating Action Button (로그인한 경우만) -->
	{#if isLoggedIn}
		<a
			href="/create"
			class="fixed right-6 bottom-20 md:bottom-24 w-14 h-14 bg-[#bfa094] text-white rounded-full shadow-lg flex items-center justify-center hover:bg-[#a18072] hover:scale-110 transition-all z-40 group"
		>
			<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2.5"
					d="M12 4v16m8-8H4"
				/>
			</svg>
		</a>
	{/if}

		{#if loading}
			<div class="text-center py-20">
				<p class="text-[#9ca3af]">로딩중...</p>
			</div>
		{:else if error}
			<div class="text-center py-20">
				<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
					<svg class="w-16 h-16 mx-auto mb-4 text-[#9ca3af]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
					<p class="text-[#7f6251] mb-2">게시물을 불러올 수 없습니다</p>
					<p class="text-sm text-[#9ca3af] mb-4">{error}</p>
					<button
						onclick={loadPosts}
						class="px-6 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors"
					>
						다시 시도
					</button>
				</div>
			</div>
		{:else if posts.length === 0}
			<div class="text-center py-20">
				<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
					<div class="text-6xl mb-4">☕</div>
					<p class="text-xl font-semibold text-[#5d4a3f] mb-2">Feed가 없습니다</p>
					<p class="text-[#9ca3af] mb-6">아직 피드에 게시물이 없습니다</p>
					<a
						href="/create"
						class="inline-block px-6 py-3 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors font-medium"
					>
						첫 게시물 작성하기
					</a>
				</div>
			</div>
		{:else}
			<!-- Feed Posts -->
			{#each posts as post (post.id)}
				<div class="bg-white rounded-lg shadow-sm border border-[#e5e7eb] mb-4">
					<!-- Post Header -->
					<div class="p-4 flex items-center justify-between">
						<div class="flex items-center space-x-3">
							<div class="w-10 h-10 rounded-full bg-[#f2e8e5] flex items-center justify-center overflow-hidden">
								{#if post.author.avatar_url}
									<img
										src={post.author.avatar_url}
										alt={post.author.username || ''}
										class="w-full h-full object-cover"
									/>
								{:else}
									<span class="text-sm font-semibold text-[#bfa094]">
										{getInitial(post.author.full_name || post.author.username)}
									</span>
								{/if}
							</div>
							<div>
								<p class="text-sm font-semibold text-[#5d4a3f]">
									{post.author.full_name || post.author.username || 'Unknown'}
								</p>
								<p class="text-xs text-[#9ca3af]">{getTimeAgo(post.created_at)}</p>
							</div>
						</div>
						<button class="text-[#9ca3af] hover:text-[#5d4a3f]">
							<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
								<path
									d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"
								/>
							</svg>
						</button>
					</div>

					<!-- Post Content -->
					<div class="px-4 pb-3">
						<p class="text-[#5d4a3f] whitespace-pre-wrap">{post.content}</p>
						{#if post.images && post.images.length > 0}
							<ImageGrid images={post.images} />
						{/if}
					</div>

					<!-- Tags -->
					{#if post.tags && post.tags.length > 0}
						<div class="px-4 pb-3 flex flex-wrap gap-2">
							{#each post.tags as tag}
								<span class="text-xs text-[#bfa094] bg-[#f2e8e5] px-2 py-1 rounded">#{tag}</span>
							{/each}
						</div>
					{/if}

					<!-- Likes/Comments Count -->
					<div class="px-4 py-2 flex items-center justify-between text-xs text-[#9ca3af]">
						<span>좋아요 {post.likes_count}개</span>
						<span>댓글 {post.comments_count}개</span>
					</div>

					<!-- Action Buttons -->
					<div class="border-t border-[#e5e7eb] px-2 py-1 flex items-center justify-around">
						<button
							onclick={() => toggleLike(post.id)}
							class="flex items-center justify-center p-2 rounded-lg transition-colors {post.hasLiked
								? 'text-red-500 bg-red-50'
								: 'text-[#7f6251] hover:bg-[#f9fafb]'}"
						>
							<svg
								class="w-6 h-6"
								fill={post.hasLiked ? 'currentColor' : 'none'}
								stroke="currentColor"
								viewBox="0 0 24 24"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
								/>
							</svg>
						</button>
						<a
							href="/posts/{post.id}"
							class="flex items-center justify-center text-[#7f6251] hover:bg-[#f9fafb] p-2 rounded-lg transition-colors"
						>
							<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
								/>
							</svg>
						</a>
						<button
							class="flex items-center justify-center text-[#7f6251] hover:bg-[#f9fafb] p-2 rounded-lg transition-colors"
						>
							<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"
								/>
							</svg>
						</button>
					</div>
				</div>
			{/each}
		{/if}
</div>
