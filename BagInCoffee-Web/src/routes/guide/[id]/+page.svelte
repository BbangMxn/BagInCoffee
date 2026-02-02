<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { guideApi } from '$lib/api';
	import type { CoffeeGuide } from '$lib/types/content';
	import { marked } from 'marked';

	let guide: CoffeeGuide | null = null;
	let loading = true;
	let error: string | null = null;
	let renderedContent: string = '';

	const difficultyLabels = {
		beginner: '초급',
		intermediate: '중급',
		advanced: '고급',
		master: '전문가'
	};

	const difficultyColors = {
		beginner: 'bg-green-100 text-green-800',
		intermediate: 'bg-blue-100 text-blue-800',
		advanced: 'bg-orange-100 text-orange-800',
		master: 'bg-red-100 text-red-800'
	};

	const categoryLabels: Record<string, string> = {
		brewing: '추출 방법',
		beans: '원두 가이드',
		equipment: '장비 사용법',
		'latte-art': '라떼 아트',
		roasting: '로스팅',
		other: '기타'
	};

	async function loadGuide() {
		loading = true;
		error = null;

		const id = $page.params.id;
		const response = await guideApi.getById(id);

		if (response.success && response.data) {
			guide = response.data;
			// Render markdown to HTML
			renderedContent = await marked(guide.content, {
				breaks: true,
				gfm: true
			});
		} else {
			error = response.error?.message || '가이드를 불러오는데 실패했습니다';
		}

		loading = false;
	}

	function formatViews(views: number): string {
		if (views >= 1000) {
			return `${(views / 1000).toFixed(1)}k`;
		}
		return views.toString();
	}

	onMount(() => {
		loadGuide();
	});
</script>

<svelte:head>
	{#if guide}
		<title>{guide.title} - BagInCoffee</title>
		<meta name="description" content={guide.content.substring(0, 160)} />
	{/if}
</svelte:head>

<div class="max-w-4xl mx-auto px-4 py-6">
	{#if loading}
		<div class="text-center py-20">
			<p class="text-[#9ca3af] text-lg">로딩 중...</p>
		</div>
	{:else if error}
		<div class="text-center py-20">
			<p class="text-red-600 text-lg">{error}</p>
			<a href="/guide" class="mt-4 inline-block text-[#bfa094] hover:text-[#a88f84]">
				← 가이드 목록으로
			</a>
		</div>
	{:else if guide}
		<!-- Breadcrumb -->
		<div class="mb-4 text-sm text-[#7f6251]">
			<a href="/guide" class="hover:text-[#5d4a3f]">커피 가이드</a>
			<span class="mx-2">→</span>
			<span class="text-[#5d4a3f] font-medium">{guide.title}</span>
		</div>

		<!-- Header -->
		<article class="bg-white rounded-lg border border-[#e5e7eb] overflow-hidden">
			{#if guide.thumbnail_url}
				<img
					src={guide.thumbnail_url}
					alt={guide.title}
					class="w-full h-64 object-cover"
				/>
			{/if}

			<div class="p-6 md:p-8">
				<!-- Meta -->
				<div class="flex items-center gap-2 mb-4 flex-wrap">
					<span class="px-3 py-1 bg-[#f2e8e5] text-[#7f6251] text-sm rounded-full">
						{categoryLabels[guide.category] || guide.category}
					</span>
					<span
						class={`px-3 py-1 text-sm rounded-full ${difficultyColors[guide.difficulty]}`}
					>
						{difficultyLabels[guide.difficulty]}
					</span>
					<span class="text-sm text-[#9ca3af]">
						{guide.estimated_time}분 읽기
					</span>
					<span class="text-sm text-[#9ca3af]">
						조회 {formatViews(guide.views_count || 0)}
					</span>
				</div>

				<!-- Title -->
				<h1 class="text-3xl md:text-4xl font-bold text-[#5d4a3f] mb-6">
					{guide.title}
				</h1>

				<!-- Content (Markdown Rendered) -->
				<div class="prose prose-lg max-w-none markdown-content">
					{@html renderedContent}
				</div>

				<!-- Footer -->
				<div class="mt-12 pt-6 border-t border-[#e5e7eb]">
					<a
						href="/guide"
						class="inline-flex items-center text-[#bfa094] hover:text-[#a88f84] font-medium"
					>
						<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M10 19l-7-7m0 0l7-7m-7 7h18"
							/>
						</svg>
						가이드 목록으로 돌아가기
					</a>
				</div>
			</div>
		</article>
	{/if}
</div>

<style>
	/* Markdown Content Styles */
	:global(.markdown-content) {
		color: #5d4a3f;
		line-height: 1.8;
	}

	:global(.markdown-content h1) {
		font-size: 2rem;
		font-weight: 700;
		color: #5d4a3f;
		margin-top: 2rem;
		margin-bottom: 1rem;
		padding-bottom: 0.5rem;
		border-bottom: 2px solid #e5e7eb;
	}

	:global(.markdown-content h2) {
		font-size: 1.75rem;
		font-weight: 700;
		color: #5d4a3f;
		margin-top: 2rem;
		margin-bottom: 1rem;
	}

	:global(.markdown-content h3) {
		font-size: 1.5rem;
		font-weight: 600;
		color: #7f6251;
		margin-top: 1.5rem;
		margin-bottom: 0.75rem;
	}

	:global(.markdown-content h4) {
		font-size: 1.25rem;
		font-weight: 600;
		color: #7f6251;
		margin-top: 1.25rem;
		margin-bottom: 0.75rem;
	}

	:global(.markdown-content p) {
		margin-bottom: 1rem;
	}

	:global(.markdown-content a) {
		color: #bfa094;
		text-decoration: underline;
	}

	:global(.markdown-content a:hover) {
		color: #a88f84;
	}

	:global(.markdown-content ul),
	:global(.markdown-content ol) {
		margin-left: 1.5rem;
		margin-bottom: 1rem;
	}

	:global(.markdown-content li) {
		margin-bottom: 0.5rem;
	}

	:global(.markdown-content blockquote) {
		border-left: 4px solid #bfa094;
		padding-left: 1rem;
		margin-left: 0;
		margin-bottom: 1rem;
		color: #7f6251;
		font-style: italic;
		background: #fdf8f6;
		padding: 1rem;
		border-radius: 0 0.5rem 0.5rem 0;
	}

	:global(.markdown-content code) {
		background: #f2e8e5;
		padding: 0.2rem 0.4rem;
		border-radius: 0.25rem;
		font-size: 0.9em;
		color: #5d4a3f;
		font-family: 'Courier New', monospace;
	}

	:global(.markdown-content pre) {
		background: #f2e8e5;
		padding: 1rem;
		border-radius: 0.5rem;
		overflow-x: auto;
		margin-bottom: 1rem;
	}

	:global(.markdown-content pre code) {
		background: none;
		padding: 0;
		font-size: 0.9rem;
	}

	:global(.markdown-content img) {
		max-width: 100%;
		height: auto;
		border-radius: 0.5rem;
		margin: 1.5rem 0;
	}

	:global(.markdown-content table) {
		width: 100%;
		border-collapse: collapse;
		margin-bottom: 1rem;
	}

	:global(.markdown-content table th),
	:global(.markdown-content table td) {
		border: 1px solid #e5e7eb;
		padding: 0.75rem;
		text-align: left;
	}

	:global(.markdown-content table th) {
		background: #f2e8e5;
		font-weight: 600;
		color: #5d4a3f;
	}

	:global(.markdown-content hr) {
		border: none;
		border-top: 2px solid #e5e7eb;
		margin: 2rem 0;
	}

	:global(.markdown-content strong) {
		font-weight: 700;
		color: #5d4a3f;
	}

	:global(.markdown-content em) {
		font-style: italic;
	}
</style>
