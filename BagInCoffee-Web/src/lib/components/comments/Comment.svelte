<script lang="ts">
	import type { Comment } from '$lib/types/comment';
	import { enhance } from '$app/forms';

	interface Props {
		comment: Comment;
		postId: string;
		userId?: string;
		onReply?: (commentId: string) => void;
	}

	let { comment, postId, userId, onReply }: Props = $props();

	let isEditing = $state(false);
	let editContent = $state(comment.content);
	let showDeleteConfirm = $state(false);

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

	const isOwner = $derived(userId === comment.user_id);
	const displayName = $derived(
		comment.profiles?.full_name || comment.profiles?.username || '익명'
	);
</script>

<div class="flex gap-3">
	<!-- Avatar -->
	<div class="flex-shrink-0">
		<div
			class="w-8 h-8 rounded-full bg-[#f2e8e5] flex items-center justify-center overflow-hidden"
		>
			{#if comment.profiles?.avatar_url}
				<img
					src={comment.profiles.avatar_url}
					alt={displayName}
					class="w-full h-full object-cover"
				/>
			{:else}
				<span class="text-xs font-semibold text-[#bfa094]">
					{getInitial(displayName)}
				</span>
			{/if}
		</div>
	</div>

	<!-- Content -->
	<div class="flex-1 min-w-0">
		<!-- Header -->
		<div class="flex items-center gap-2 mb-1">
			<span class="text-sm font-semibold text-[#5d4a3f]">{displayName}</span>
			<span class="text-xs text-[#9ca3af]">{formatTimeAgo(comment.created_at)}</span>
			{#if comment.updated_at !== comment.created_at}
				<span class="text-xs text-[#9ca3af]">(수정됨)</span>
			{/if}
		</div>

		<!-- Content or Edit Form -->
		{#if isEditing}
			<form method="POST" action="?/updateComment" use:enhance>
				<input type="hidden" name="comment_id" value={comment.id} />
				<textarea
					name="content"
					bind:value={editContent}
					class="w-full px-3 py-2 border border-[#e5e7eb] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent resize-none text-sm"
					rows="3"
					maxlength="1000"
				></textarea>
				<div class="flex gap-2 mt-2">
					<button
						type="submit"
						class="px-3 py-1.5 bg-[#bfa094] text-white text-xs rounded-lg hover:bg-[#a88f84] transition-colors"
					>
						저장
					</button>
					<button
						type="button"
						onclick={() => {
							isEditing = false;
							editContent = comment.content;
						}}
						class="px-3 py-1.5 bg-gray-200 text-gray-700 text-xs rounded-lg hover:bg-gray-300 transition-colors"
					>
						취소
					</button>
				</div>
			</form>
		{:else}
			<p class="text-sm text-[#5d4a3f] whitespace-pre-wrap break-words">{comment.content}</p>

			<!-- Actions -->
			<div class="flex items-center gap-4 mt-2">
				{#if userId}
					<button
						onclick={() => onReply?.(comment.id)}
						class="text-xs text-[#7f6251] hover:text-[#5d4a3f] font-medium"
					>
						답글
					</button>
				{/if}

				{#if isOwner}
					<button
						onclick={() => (isEditing = true)}
						class="text-xs text-[#7f6251] hover:text-[#5d4a3f] font-medium"
					>
						수정
					</button>
					<button
						onclick={() => (showDeleteConfirm = true)}
						class="text-xs text-red-600 hover:text-red-700 font-medium"
					>
						삭제
					</button>
				{/if}
			</div>
		{/if}

		<!-- Delete Confirmation -->
		{#if showDeleteConfirm}
			<div class="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
				<p class="text-sm text-red-800 mb-2">정말 삭제하시겠습니까?</p>
				<div class="flex gap-2">
					<form method="POST" action="?/deleteComment" use:enhance>
						<input type="hidden" name="comment_id" value={comment.id} />
						<button
							type="submit"
							class="px-3 py-1.5 bg-red-600 text-white text-xs rounded-lg hover:bg-red-700 transition-colors"
						>
							삭제
						</button>
					</form>
					<button
						type="button"
						onclick={() => (showDeleteConfirm = false)}
						class="px-3 py-1.5 bg-gray-200 text-gray-700 text-xs rounded-lg hover:bg-gray-300 transition-colors"
					>
						취소
					</button>
				</div>
			</div>
		{/if}

		<!-- Replies -->
		{#if comment.replies && comment.replies.length > 0}
			<div class="mt-4 space-y-4 pl-4 border-l-2 border-[#f2e8e5]">
				{#each comment.replies as reply (reply.id)}
					<svelte:self comment={reply} {postId} {userId} {onReply} />
				{/each}
			</div>
		{/if}
	</div>
</div>
