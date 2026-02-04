<script lang="ts">
	import { onMount } from 'svelte';
	import { guideApi } from '$lib/api';
	import type { CoffeeGuide, GuideCategory } from '$lib/types/content';

	// 포트폴리오용 목업 데이터
	const MOCK_GUIDES: CoffeeGuide[] = [
		{
			id: '1',
			title: '에스프레소 추출의 기초: 완벽한 샷을 위한 가이드',
			content: '에스프레소는 커피의 정수입니다. 올바른 그라인딩, 탬핑, 추출 시간을 통해 완벽한 샷을 만들어보세요. 이 가이드에서는 초보자도 쉽게 따라할 수 있는 단계별 에스프레소 추출 방법을 알려드립니다.',
			category: 'brewing',
			difficulty: 'beginner',
			estimated_time: 8,
			views_count: 15420,
			thumbnail_url: 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400',
			created_at: '2025-01-15'
		},
		{
			id: '2',
			title: '핸드드립 V60 마스터하기',
			content: 'V60는 가장 인기있는 핸드드립 도구입니다. 물줄기 조절, 뜸 들이기, 추출 속도 등 V60만의 특별한 기술을 배워보세요. 원두의 풍미를 최대한 살릴 수 있습니다.',
			category: 'brewing',
			difficulty: 'intermediate',
			estimated_time: 12,
			views_count: 8930,
			thumbnail_url: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
			created_at: '2025-01-10'
		},
		{
			id: '3',
			title: '에티오피아 예가체프 원두 완벽 가이드',
			content: '에티오피아 예가체프는 플로럴하고 과일향이 풍부한 원두입니다. 적합한 로스팅 포인트, 추천 추출 방식, 그리고 최적의 맛을 내는 방법을 알아봅니다.',
			category: 'beans',
			difficulty: 'beginner',
			estimated_time: 6,
			views_count: 12100,
			thumbnail_url: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400',
			created_at: '2025-01-08'
		},
		{
			id: '4',
			title: '라떼 아트: 하트 그리기 완전 정복',
			content: '라떼 아트의 기본인 하트 패턴부터 시작해보세요. 우유 스티밍의 기초, 적절한 온도, 붓기 기술까지 상세하게 설명합니다. 연습을 통해 아름다운 하트를 그려보세요.',
			category: 'latte-art',
			difficulty: 'intermediate',
			estimated_time: 15,
			views_count: 23500,
			thumbnail_url: 'https://images.unsplash.com/photo-1534778101976-62847782c213?w=400',
			created_at: '2025-01-05'
		},
		{
			id: '5',
			title: '그라인더 선택 가이드: 입문자를 위한 추천',
			content: '좋은 커피의 시작은 그라인더입니다. 수동 그라인더와 전동 그라인더의 차이, 가격대별 추천 제품, 그리고 관리 방법까지 입문자에게 필요한 모든 정보를 담았습니다.',
			category: 'equipment',
			difficulty: 'beginner',
			estimated_time: 10,
			views_count: 18200,
			thumbnail_url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
			created_at: '2025-01-02'
		},
		{
			id: '6',
			title: '홈 로스팅 입문: 프라이팬으로 시작하기',
			content: '집에서도 신선한 원두를 즐길 수 있습니다. 프라이팬을 이용한 간단한 홈 로스팅 방법부터 로스팅 포인트 판별법까지, 홈 로스팅의 세계로 안내합니다.',
			category: 'roasting',
			difficulty: 'advanced',
			estimated_time: 20,
			views_count: 9870,
			thumbnail_url: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400',
			created_at: '2024-12-28'
		}
	];

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

		// 포트폴리오용: 목업 데이터 사용
		await new Promise(r => setTimeout(r, 300)); // 로딩 효과
		
		if (selectedCategory === 'all') {
			guides = MOCK_GUIDES;
		} else {
			guides = MOCK_GUIDES.filter(g => g.category === selectedCategory);
		}
		totalPages = 1;
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
