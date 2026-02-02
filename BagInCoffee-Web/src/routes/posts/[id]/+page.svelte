<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import ImageGrid from '$lib/components/feed/ImageGrid.svelte';
	import Comment from '$lib/components/comments/Comment.svelte';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let newCommentContent = $state('');
	let replyToCommentId = $state<string | null>(null);
	let replyContent = $state('');
	let showLikedUsers = $state(false);

	function formatTimeAgo(dateString: string): string {
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
		return name.charAt(0).toUpperCase();
	}

	function handleReply(commentId: string) {
		replyToCommentId = commentId;
		// Scroll to reply form
		setTimeout(() => {
			document.getElementById('reply-form')?.scrollIntoView({ behavior: 'smooth' });
			document.getElementById('reply-input')?.focus();
		}, 100);
	}

	function cancelReply() {
		replyToCommentId = null;
		replyContent = '';
	}

	const isLoggedIn = $derived(!!data.session);
	const displayName = $derived(
		data.post.author.full_name || data.post.author.username || '익명'
	);
</script>

<div class="min-h-screen bg-gray-50">
	<div class="max-w-2xl mx-auto px-4 py-4">
		<!-- Back Button -->
		<button
			onclick={() => goto('/')}
			class="flex items-center gap-2 text-sm text-[#7f6251] hover:text-[#5d4a3f] mb-4"
		>
			<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M15 19l-7-7 7-7"
				/>
			</svg>
			돌아가기
		</button>

		<!-- Post Card -->
		<div class="bg-white rounded-lg shadow-sm border border-[#e5e7eb] mb-4">
			<!-- Post Header -->
			<div class="p-4 flex items-center justify-between">
				<div class="flex items-center space-x-3">
					<div
						class="w-10 h-10 rounded-full bg-[#f2e8e5] flex items-center justify-center overflow-hidden"
					>
						{#if data.post.author.avatar_url}
							<img
								src={data.post.author.avatar_url}
								alt={displayName}
								class="w-full h-full object-cover"
							/>
						{:else}
							<span class="text-sm font-semibold text-[#bfa094]">
								{getInitial(displayName)}
							</span>
						{/if}
					</div>
					<div>
						<p class="text-sm font-semibold text-[#5d4a3f]">
							{displayName}
						</p>
						<p class="text-xs text-[#9ca3af]">{formatTimeAgo(data.post.created_at)}</p>
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
				<p class="text-[#5d4a3f] whitespace-pre-wrap">{data.post.content}</p>
				{#if data.post.images && data.post.images.length > 0}
					<ImageGrid images={data.post.images} />
				{/if}
			</div>

			<!-- Tags -->
			{#if data.post.tags && data.post.tags.length > 0}
				<div class="px-4 pb-3 flex flex-wrap gap-2">
					{#each data.post.tags as tag}
						<span class="text-xs text-[#bfa094] bg-[#f2e8e5] px-2 py-1 rounded">#{tag}</span>
					{/each}
				</div>
			{/if}

			<!-- Likes/Comments Count -->
			<div class="px-4 py-2 flex items-center justify-between text-xs text-[#9ca3af]">
				<button
					onclick={() => (showLikedUsers = !showLikedUsers)}
					class="hover:text-[#5d4a3f] transition-colors"
				>
					좋아요 {data.post.likes_count}개
				</button>
				<span>댓글 {data.post.comments_count}개</span>
			</div>

			<!-- Action Buttons -->
			<div class="border-t border-[#e5e7eb] px-2 py-1 flex items-center justify-around">
				<form method="POST" action="?/toggleLike" use:enhance class="flex-1">
					<button
						type="submit"
						class="w-full flex items-center justify-center p-2 rounded-lg transition-colors {data.post
							.hasLiked
							? 'text-red-500 bg-red-50'
							: 'text-[#7f6251] hover:bg-[#f9fafb]'}"
					>
						<svg
							class="w-6 h-6"
							fill={data.post.hasLiked ? 'currentColor' : 'none'}
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
				</form>
				<button
					onclick={() => document.getElementById('comment-input')?.focus()}
					class="flex-1 flex items-center justify-center text-[#7f6251] hover:bg-[#f9fafb] p-2 rounded-lg transition-colors"
				>
					<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
						/>
					</svg>
				</button>
				<button
					class="flex-1 flex items-center justify-center text-[#7f6251] hover:bg-[#f9fafb] p-2 rounded-lg transition-colors"
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

		<!-- Comments Section -->
		<div class="bg-white rounded-lg shadow-sm border border-[#e5e7eb] p-4">
			<h2 class="text-lg font-semibold text-[#5d4a3f] mb-4">
				댓글 {data.comments.length}개
			</h2>

			<!-- Comment Input -->
			{#if isLoggedIn}
				<form method="POST" action="?/createComment" use:enhance class="mb-6">
					<textarea
						id="comment-input"
						name="content"
						bind:value={newCommentContent}
						placeholder="댓글을 입력하세요..."
						class="w-full px-4 py-3 border border-[#e5e7eb] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent resize-none"
						rows="3"
						maxlength="1000"
					></textarea>
					<div class="flex items-center justify-between mt-2">
						<span class="text-xs text-[#9ca3af]">{newCommentContent.length} / 1000</span>
						<button
							type="submit"
							disabled={!newCommentContent.trim()}
							class="px-4 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
						>
							댓글 작성
						</button>
					</div>
				</form>
			{:else}
				<div class="p-4 bg-[#f2e8e5] rounded-lg text-center mb-6">
					<p class="text-sm text-[#5d4a3f] mb-2">댓글을 작성하려면 로그인이 필요합니다</p>
					<a
						href="/login"
						class="inline-block px-4 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors text-sm"
					>
						로그인
					</a>
				</div>
			{/if}

			<!-- Reply Form (shown when replying) -->
			{#if replyToCommentId}
				<div id="reply-form" class="mb-6 p-4 bg-[#f9fafb] border border-[#e5e7eb] rounded-lg">
					<div class="flex items-center justify-between mb-3">
						<span class="text-sm font-medium text-[#5d4a3f]">답글 작성</span>
						<button
							onclick={cancelReply}
							class="text-xs text-[#9ca3af] hover:text-[#5d4a3f]"
						>
							취소
						</button>
					</div>
					<form method="POST" action="?/createComment" use:enhance>
						<input type="hidden" name="parent_comment_id" value={replyToCommentId} />
						<textarea
							id="reply-input"
							name="content"
							bind:value={replyContent}
							placeholder="답글을 입력하세요..."
							class="w-full px-4 py-3 border border-[#e5e7eb] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent resize-none"
							rows="3"
							maxlength="1000"
						></textarea>
						<div class="flex items-center justify-between mt-2">
							<span class="text-xs text-[#9ca3af]">{replyContent.length} / 1000</span>
							<button
								type="submit"
								disabled={!replyContent.trim()}
								class="px-4 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
							>
								답글 작성
							</button>
						</div>
					</form>
				</div>
			{/if}

			<!-- Comments List -->
			{#if data.comments.length === 0}
				<div class="text-center py-12">
					<div class="text-5xl mb-3">💬</div>
					<p class="text-[#9ca3af]">첫 댓글을 작성해보세요!</p>
				</div>
			{:else}
				<div class="space-y-6">
					{#each data.comments as comment (comment.id)}
						<Comment
							{comment}
							postId={data.post.id}
							userId={data.session?.user.id}
							onReply={handleReply}
						/>
					{/each}
				</div>
			{/if}
		</div>
	</div>
</div>
