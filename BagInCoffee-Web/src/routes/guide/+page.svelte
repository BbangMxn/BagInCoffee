<script lang="ts">
	import { onMount } from 'svelte';
	import { guideApi } from '$lib/api';
	import type { CoffeeGuide, GuideCategory } from '$lib/types/content';

	let guides: CoffeeGuide[] = [];
	let loading = true;
	let error: string | null = null;
	let selectedCategory: GuideCategory | 'all' = 'all';
	let page = 1;
	let totalPages = 1;

	const categories: { value: GuideCategory | 'all'; label: string }[] = [
		{ value: 'all', label: '전체' },
		{ value: 'brewing', label: '추출 방법' },
		{ value: 'beans', label: '원두 가이드' },
		{ value: 'equipment', label: '장비 사용법' },
		{ value: 'latte-art', label: '라떼 아트' },
		{ value: 'roasting', label: '로스팅' },
		{ value: 'other', label: '기타' }
	];

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

	async function loadGuides() {
		loading = true;
		error = null;

		const params: any = { page, page_size: 10 };
		if (selectedCategory !== 'all') {
			params.category = selectedCategory;
		}

		const response = await guideApi.getAll(params);

		if (response.success && response.data) {
			guides = response.data;
			totalPages = response.pagination?.total_pages || 1;
		} else {
			error = response.error?.message || '가이드를 불러오는데 실패했습니다';
		}

		loading = false;
	}

	function selectCategory(category: GuideCategory | 'all') {
		selectedCategory = category;
		page = 1;
		loadGuides();
	}

	function nextPage() {
		if (page < totalPages) {
			page++;
			loadGuides();
		}
	}

	function prevPage() {
		if (page > 1) {
			page--;
			loadGuides();
		}
	}

	function formatViews(views: number): string {
		if (views >= 1000) {
			return `${(views / 1000).toFixed(1)}k`;
		}
		return views.toString();
	}

	onMount(() => {
		loadGuides();
	});
</script>

<div class="max-w-4xl mx-auto px-4 py-4">
	<h1 class="text-2xl font-bold text-[#5d4a3f] mb-6">커피 가이드</h1>

	<!-- 카테고리 필터 -->
	<div class="flex space-x-2 mb-6 overflow-x-auto">
		{#each categories as category}
			<button
				onclick={() => selectCategory(category.value)}
				class={`px-4 py-2 rounded-full text-sm whitespace-nowrap transition-colors ${
					selectedCategory === category.value
						? 'bg-[#bfa094] text-white'
						: 'bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f2e8e5]'
				}`}
			>
				{category.label}
			</button>
		{/each}
	</div>

	<!-- 가이드 카드 리스트 -->
	{#if loading}
		<div class="text-center py-20">
			<p class="text-[#9ca3af] text-lg">로딩 중...</p>
		</div>
	{:else if error}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<svg class="w-16 h-16 mx-auto mb-4 text-[#9ca3af]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
				</svg>
				<p class="text-[#7f6251] mb-2">데이터를 불러올 수 없습니다</p>
				<p class="text-sm text-[#9ca3af] mb-4">{error}</p>
				<button
					onclick={loadGuides}
					class="px-6 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors"
				>
					다시 시도
				</button>
			</div>
		</div>
	{:else if guides.length === 0}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<div class="text-6xl mb-4">📖</div>
				<p class="text-xl font-semibold text-[#5d4a3f] mb-2">데이터가 없습니다</p>
				<p class="text-[#9ca3af]">
					{#if selectedCategory !== 'all'}
						선택한 카테고리에 가이드가 없습니다
					{:else}
						아직 작성된 가이드가 없습니다
					{/if}
				</p>
			</div>
		</div>
	{:else}
		<div class="space-y-4">
			{#each guides as guide (guide.id)}
				<a
					href="/guide/{guide.id}"
					class="block bg-white rounded-lg shadow-sm border border-[#e5e7eb] overflow-hidden hover:shadow-md transition-shadow"
				>
					<div class="flex">
						{#if guide.thumbnail_url}
							<img
								src={guide.thumbnail_url}
								alt={guide.title}
								class="w-32 h-32 flex-shrink-0 object-cover"
							/>
						{:else}
							<div class="w-32 h-32 bg-[#f2e8e5] flex-shrink-0 flex items-center justify-center">
								<span class="text-4xl">☕</span>
							</div>
						{/if}
						<div class="flex-1 p-4">
							<div class="flex items-center gap-2 mb-2">
								<span class="inline-block px-2 py-1 bg-[#f2e8e5] text-[#7f6251] text-xs rounded">
									{categories.find((c) => c.value === guide.category)?.label || guide.category}
								</span>
								<span
									class={`inline-block px-2 py-1 text-xs rounded ${difficultyColors[guide.difficulty]}`}
								>
									{difficultyLabels[guide.difficulty]}
								</span>
							</div>
							<h3 class="text-lg font-semibold text-[#5d4a3f] mb-2">{guide.title}</h3>
							<p class="text-sm text-[#9ca3af] mb-3 line-clamp-2">
								{guide.content.substring(0, 100).replace(/[#*\n]/g, '')}...
							</p>
							<div class="flex items-center text-xs text-[#9ca3af]">
								<span>{guide.estimated_time}분 읽기</span>
								<span class="mx-2">•</span>
								<span>조회 {formatViews(guide.views_count || 0)}</span>
							</div>
						</div>
					</div>
				</a>
			{/each}
		</div>

		<!-- 페이지네이션 -->
		{#if totalPages > 1}
			<div class="flex justify-center items-center gap-4 mt-8">
				<button
					onclick={prevPage}
					disabled={page === 1}
					class="px-4 py-2 bg-white text-[#7f6251] border border-[#e5e7eb] rounded-lg hover:bg-[#f2e8e5] disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
				>
					이전
				</button>
				<span class="text-sm text-[#7f6251]">{page} / {totalPages}</span>
				<button
					onclick={nextPage}
					disabled={page === totalPages}
					class="px-4 py-2 bg-white text-[#7f6251] border border-[#e5e7eb] rounded-lg hover:bg-[#f2e8e5] disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
				>
					다음
				</button>
			</div>
		{/if}
	{/if}
</div>
