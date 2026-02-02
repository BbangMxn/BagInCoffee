<script lang="ts">
	import { onMount } from 'svelte';
	import { postsApi } from '$lib/api';
	import type { PostWithAuthor } from '$lib/types/Post';

	let posts: PostWithAuthor[] = [];
	let loading = true;
	let error: string | null = null;
	let page = 1;
	let totalPages = 1;

	async function loadFeed() {
		loading = true;
		error = null;

		const response = await postsApi.getFeed({ page, page_size: 20 });

		if (response.success && response.data) {
			posts = response.data;
			totalPages = response.pagination?.total_pages || 1;
		} else {
			error = response.error?.message || 'Failed to load feed';
		}

		loading = false;
	}

	async function toggleLike(postId: string) {
		const response = await postsApi.toggleLike(postId);

		if (response.success) {
			// UI 업데이트
			posts = posts.map((post) => {
				if (post.id === postId) {
					return {
						...post,
						hasLiked: response.data?.liked,
						likes_count: post.likes_count + (response.data?.liked ? 1 : -1)
					};
				}
				return post;
			});
		}
	}

	function nextPage() {
		if (page < totalPages) {
			page++;
			loadFeed();
		}
	}

	function prevPage() {
		if (page > 1) {
			page--;
			loadFeed();
		}
	}

	onMount(() => {
		loadFeed();
	});
</script>

<div class="feed-container">
	<h1>피드</h1>

	{#if loading}
		<div class="loading">로딩중...</div>
	{:else if error}
		<div class="error">{error}</div>
	{:else}
		<div class="posts">
			{#each posts as post (post.id)}
				<article class="post">
					<header>
						<img src={post.author.avatar_url || '/default-avatar.png'} alt={post.author.username || ''} />
						<div>
							<h3>{post.author.full_name || post.author.username}</h3>
							<time>{new Date(post.created_at).toLocaleDateString()}</time>
						</div>
					</header>

					<div class="content">
						<p>{post.content}</p>
						{#if post.images && post.images.length > 0}
							<img src={post.images[0]} alt="Post" />
						{/if}
					</div>

					<footer>
						<button on:click={() => toggleLike(post.id)} class:liked={post.hasLiked}>
							{post.hasLiked ? '❤️' : '🤍'} {post.likes_count}
						</button>
						<span>💬 {post.comments_count}</span>
					</footer>

					{#if post.tags && post.tags.length > 0}
						<div class="tags">
							{#each post.tags as tag}
								<span class="tag">#{tag}</span>
							{/each}
						</div>
					{/if}
				</article>
			{/each}
		</div>

		<div class="pagination">
			<button on:click={prevPage} disabled={page === 1}>이전</button>
			<span>{page} / {totalPages}</span>
			<button on:click={nextPage} disabled={page === totalPages}>다음</button>
		</div>
	{/if}
</div>

<style>
	.feed-container {
		max-width: 600px;
		margin: 0 auto;
		padding: 20px;
	}

	.loading,
	.error {
		text-align: center;
		padding: 40px;
	}

	.error {
		color: red;
	}

	.posts {
		display: flex;
		flex-direction: column;
		gap: 20px;
	}

	.post {
		border: 1px solid #ddd;
		border-radius: 8px;
		padding: 16px;
		background: white;
	}

	.post header {
		display: flex;
		align-items: center;
		gap: 12px;
		margin-bottom: 12px;
	}

	.post header img {
		width: 40px;
		height: 40px;
		border-radius: 50%;
		object-fit: cover;
	}

	.post header h3 {
		margin: 0;
		font-size: 14px;
		font-weight: 600;
	}

	.post header time {
		font-size: 12px;
		color: #666;
	}

	.content p {
		margin: 0 0 12px 0;
	}

	.content img {
		width: 100%;
		border-radius: 8px;
	}

	.post footer {
		display: flex;
		gap: 16px;
		margin-top: 12px;
	}

	.post footer button {
		background: none;
		border: none;
		cursor: pointer;
		font-size: 14px;
		display: flex;
		align-items: center;
		gap: 4px;
	}

	.post footer button.liked {
		color: red;
	}

	.tags {
		display: flex;
		gap: 8px;
		margin-top: 12px;
		flex-wrap: wrap;
	}

	.tag {
		background: #f0f0f0;
		padding: 4px 8px;
		border-radius: 4px;
		font-size: 12px;
		color: #666;
	}

	.pagination {
		display: flex;
		justify-content: center;
		align-items: center;
		gap: 16px;
		margin-top: 24px;
	}

	.pagination button {
		padding: 8px 16px;
		border: 1px solid #ddd;
		border-radius: 4px;
		background: white;
		cursor: pointer;
	}

	.pagination button:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}
</style>
