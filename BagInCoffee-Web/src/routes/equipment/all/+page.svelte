<script lang="ts">
	import { onMount } from 'svelte';
	import { page as pageStore } from '$app/stores';
	import { goto } from '$app/navigation';
	import { equipmentApi, brandApi } from '$lib/api';
	import type { EquipmentWithRelations, EquipmentCategory, Brand } from '$lib/types/equipment';

	let equipment = $state<EquipmentWithRelations[]>([]);
	let categories = $state<EquipmentCategory[]>([]);
	let brands = $state<Brand[]>([]);
	let loading = $state({
		equipment: true,
		categories: true,
		brands: true
	});
	let error = $state<string | null>(null);
	let page = $state(1);
	let totalPages = $state(1);
	let totalCount = $state(0);

	// 필터 상태
	let selectedBrandId = $state<string>('');
	let selectedCategoryId = $state<string>('');
	let selectedPriceRange = $state<string>('');
	let minRating = $state<number | null>(null);
	let sortBy = $state<'newest' | 'oldest' | 'rating' | 'popular'>('newest');
	let showAllBrands = $state(false);

	// URL에서 초기 필터 읽기 (최초 로딩 시에만)
	let initialLoadDone = $state(false);
	$effect(() => {
		if (!initialLoadDone) {
			const urlParams = new URLSearchParams($pageStore.url.search);
			const categoryId = urlParams.get('category_id');
			if (categoryId) {
				selectedCategoryId = categoryId;
			}
			initialLoadDone = true;
		}
	});

	// 정렬 옵션
	const sortOptions = [
		{ value: 'newest', label: '최신순' },
		{ value: 'oldest', label: '오래된순' },
		{ value: 'rating', label: '평점 높은순' },
		{ value: 'popular', label: '리뷰 많은순' }
	];

	// 평점 필터 옵션
	const ratingOptions = [
		{ value: null, label: '전체' },
		{ value: 4.5, label: '4.5점 이상' },
		{ value: 4.0, label: '4.0점 이상' },
		{ value: 3.5, label: '3.5점 이상' },
		{ value: 3.0, label: '3.0점 이상' }
	];

	// 가격대 필터 옵션 (만원 단위)
	const priceRanges = [
		{ value: '', label: '전체', min: null, max: null },
		{ value: '0-50', label: '50만원 이하', min: 0, max: 500000 },
		{ value: '50-100', label: '50만원 ~ 100만원', min: 500000, max: 1000000 },
		{ value: '100-200', label: '100만원 ~ 200만원', min: 1000000, max: 2000000 },
		{ value: '200-300', label: '200만원 ~ 300만원', min: 2000000, max: 3000000 },
		{ value: '300-500', label: '300만원 ~ 500만원', min: 3000000, max: 5000000 },
		{ value: '500+', label: '500만원 이상', min: 5000000, max: null }
	];

	async function loadCategories() {
		loading.categories = true;
		const response = await equipmentApi.getCategories();
		if (response.success && response.data) {
			categories = response.data;
		}
		loading.categories = false;
	}

	async function loadBrands() {
		loading.brands = true;
		const params: any = {};
		// 카테고리가 선택되어 있으면 해당 카테고리의 브랜드만, 아니면 전체 브랜드
		if (selectedCategoryId) {
			params.category_id = selectedCategoryId;
		}
		const response = await brandApi.getAll(params);
		if (response.success && response.data) {
			brands = response.data;
		}
		loading.brands = false;
	}

	async function loadEquipment() {
		loading.equipment = true;
		error = null;

		const params: any = { page, page_size: 24, sort_by: sortBy };
		if (selectedBrandId) params.brand_id = selectedBrandId;
		if (selectedCategoryId) params.category_id = selectedCategoryId;
		if (minRating) params.min_rating = minRating;

		// 가격 필터 추가
		if (selectedPriceRange) {
			const priceRange = priceRanges.find(r => r.value === selectedPriceRange);
			if (priceRange?.min !== null && priceRange?.min !== undefined) {
				params.min_price = priceRange.min;
			}
			if (priceRange?.max !== null && priceRange?.max !== undefined) {
				params.max_price = priceRange.max;
			}
		}

		const response = await equipmentApi.getAll(params);

		if (response.success && response.data) {
			// DB에 등록된 브랜드(brand_info)가 있는 장비만 필터링
			equipment = response.data.filter(item => item.brand_info !== null);
			totalPages = response.pagination?.total_pages || 1;
			totalCount = equipment.length; // 필터링 후 개수로 업데이트
		} else {
			error = response.error?.message || '장비를 불러오는데 실패했습니다';
		}

		loading.equipment = false;
	}

	function handleFilterChange() {
		page = 1;
		loadEquipment();
	}

	// 카테고리 변경 시 브랜드 목록 새로 로드
	$effect(() => {
		if (selectedCategoryId !== undefined) {
			loadBrands();
		}
	});

	function clearFilters() {
		selectedBrandId = '';
		selectedCategoryId = '';
		selectedPriceRange = '';
		minRating = null;
		sortBy = 'newest';
		page = 1;
		loadEquipment();
		loadBrands();
	}

	function nextPage() {
		if (page < totalPages) {
			page++;
			loadEquipment();
			window.scrollTo({ top: 0, behavior: 'smooth' });
		}
	}

	function prevPage() {
		if (page > 1) {
			page--;
			loadEquipment();
			window.scrollTo({ top: 0, behavior: 'smooth' });
		}
	}

	let hasActiveFilters = $derived(
		!!selectedBrandId || !!selectedCategoryId || !!selectedPriceRange || minRating !== null || sortBy !== 'newest'
	);

	onMount(() => {
		loadCategories();
		loadBrands();
		loadEquipment();

		// 사이드바에서 카테고리 선택 이벤트 리스닝
		const handleCategorySelect = (e: CustomEvent) => {
			selectedCategoryId = e.detail.categoryId;
			selectedBrandId = '';
			handleFilterChange();
		};

		const handleCategoryReset = () => {
			selectedCategoryId = '';
			selectedBrandId = '';
			handleFilterChange();
		};

		window.addEventListener('select-category', handleCategorySelect as EventListener);
		window.addEventListener('reset-category-filter', handleCategoryReset);

		return () => {
			window.removeEventListener('select-category', handleCategorySelect as EventListener);
			window.removeEventListener('reset-category-filter', handleCategoryReset);
		};
	});
</script>

<div class="max-w-7xl mx-auto px-4 py-6">
	<!-- Breadcrumb -->
	<div class="mb-4 text-sm text-[#7f6251]">
		<a href="/equipment" class="hover:text-[#5d4a3f]">장비</a>
		<span class="mx-2">→</span>
		<span class="text-[#5d4a3f] font-medium">전체 장비</span>
	</div>

	<!-- Header -->
	<div class="mb-6">
		<h1 class="text-3xl font-bold text-[#5d4a3f] mb-2">전체 장비</h1>
		{#if !loading.equipment && totalCount > 0}
			<p class="text-sm text-[#7f6251]">
				총 <span class="font-semibold text-[#5d4a3f]">{totalCount}</span>개의 장비
			</p>
		{/if}
	</div>

	<!-- 필터 영역 -->
	<div class="bg-white rounded-lg border border-[#e5e7eb] mb-6 overflow-hidden">
		<!-- 필터 헤더 -->
		<div class="bg-gradient-to-r from-[#fdf8f6] to-[#f9fafb] px-4 py-3 border-b border-[#e5e7eb]">
			<div class="flex items-center justify-between flex-wrap gap-3">
				<div class="flex items-center gap-3">
					<h2 class="text-base font-bold text-[#5d4a3f]">필터</h2>
					{#if hasActiveFilters}
						<span class="px-2 py-1 bg-[#bfa094] text-white text-xs rounded-full font-medium">
							{(selectedCategoryId ? 1 : 0) + (selectedBrandId ? 1 : 0) + (selectedPriceRange ? 1 : 0) + (minRating ? 1 : 0)}개 적용
						</span>
					{/if}
				</div>
				<div class="flex items-center gap-2">
					<!-- 정렬 -->
					<select
						bind:value={sortBy}
						onchange={handleFilterChange}
						class="px-3 py-1.5 border border-[#e5e7eb] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bfa094] text-sm text-[#5d4a3f] bg-white"
					>
						{#each sortOptions as option}
							<option value={option.value}>{option.label}</option>
						{/each}
					</select>
					{#if hasActiveFilters}
						<button
							onclick={clearFilters}
							class="px-3 py-1.5 text-sm text-[#bfa094] hover:text-[#a88f84] font-medium border border-[#bfa094] rounded-lg hover:bg-[#fdf8f6] transition-colors"
						>
							초기화
						</button>
					{/if}
				</div>
			</div>
		</div>

		<!-- 필터 내용 -->
		<div class="p-4 space-y-4">
			<!-- 카테고리 -->
			<div>
				<div class="flex items-center justify-between mb-2">
					<label class="text-sm font-semibold text-[#5d4a3f]">카테고리</label>
					{#if selectedCategoryId}
						<button
							onclick={() => {
								selectedCategoryId = '';
								selectedBrandId = '';
								handleFilterChange();
							}}
							class="text-xs text-[#bfa094] hover:text-[#a88f84]"
						>
							선택 해제
						</button>
					{/if}
				</div>
				<div class="flex flex-wrap gap-2">
					<button
						onclick={() => {
							selectedCategoryId = '';
							selectedBrandId = '';
							handleFilterChange();
						}}
						class={`px-3 py-1.5 h-9 rounded-md text-sm font-medium transition-all whitespace-nowrap ${
							selectedCategoryId === ''
								? 'bg-[#bfa094] text-white shadow-sm'
								: 'bg-[#f9fafb] text-[#7f6251] hover:bg-[#f2e8e5] border border-[#e5e7eb]'
						}`}
					>
						전체
					</button>
					{#if !loading.categories}
						{#each categories as category}
							<button
								onclick={() => {
									selectedCategoryId = category.id;
									selectedBrandId = '';
									handleFilterChange();
								}}
								class={`px-3 py-1.5 h-9 rounded-md text-sm font-medium transition-all whitespace-nowrap ${
									selectedCategoryId === category.id
										? 'bg-[#bfa094] text-white shadow-sm'
										: 'bg-[#f9fafb] text-[#7f6251] hover:bg-[#f2e8e5] border border-[#e5e7eb]'
								}`}
							>
								{category.name}
							</button>
						{/each}
					{/if}
				</div>
			</div>

			<!-- 브랜드 (한 줄만 표시, 더보기 가능) -->
			<div class="pt-4 border-t border-[#e5e7eb]">
				<div class="flex items-center justify-between mb-2">
					<label class="text-sm font-semibold text-[#5d4a3f]">
						브랜드
						{#if selectedCategoryId}
							<span class="ml-1 text-xs font-normal text-[#9ca3af]">
								({categories.find(c => c.id === selectedCategoryId)?.name} 카테고리)
							</span>
						{/if}
					</label>
					<div class="flex items-center gap-2">
						{#if selectedBrandId}
							<button
								onclick={() => {
									selectedBrandId = '';
									handleFilterChange();
								}}
								class="text-xs text-[#bfa094] hover:text-[#a88f84]"
							>
								선택 해제
							</button>
						{/if}
						{#if !loading.brands && brands.length > 0}
							<button
								onclick={() => showAllBrands = !showAllBrands}
								class="text-xs text-[#7f6251] hover:text-[#5d4a3f] font-medium flex items-center gap-1"
							>
								{showAllBrands ? '접기' : '전체 보기'}
								<svg
									class={`w-3 h-3 transition-transform ${showAllBrands ? 'rotate-180' : ''}`}
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
								</svg>
							</button>
						{/if}
					</div>
				</div>
				{#if loading.brands}
					<div class="text-sm text-[#9ca3af] py-2">브랜드 로딩 중...</div>
				{:else if brands.length === 0}
					<div class="text-sm text-[#9ca3af] py-2">
						{selectedCategoryId ? '이 카테고리에 등록된 브랜드가 없습니다' : '등록된 브랜드가 없습니다'}
					</div>
				{:else}
					<div class={`flex flex-wrap gap-2 ${showAllBrands ? '' : 'max-h-10 overflow-hidden'}`}>
						<button
							onclick={() => {
								selectedBrandId = '';
								handleFilterChange();
							}}
							class={`px-3 py-1.5 h-9 rounded-md text-sm font-medium transition-all whitespace-nowrap ${
								selectedBrandId === ''
									? 'bg-[#7f6251] text-white shadow-sm'
									: 'bg-[#f9fafb] text-[#7f6251] hover:bg-[#f2e8e5] border border-[#e5e7eb]'
							}`}
						>
							전체
						</button>
						{#each brands as brand}
							<button
								onclick={() => {
									selectedBrandId = brand.id;
									handleFilterChange();
								}}
								class={`px-3 py-1.5 h-9 rounded-md text-sm font-medium transition-all whitespace-nowrap ${
									selectedBrandId === brand.id
										? 'bg-[#7f6251] text-white shadow-sm'
										: 'bg-[#f9fafb] text-[#7f6251] hover:bg-[#f2e8e5] border border-[#e5e7eb]'
								}`}
							>
								{brand.name}
								{#if brand.country}
									<span class="ml-1 text-xs opacity-70">({brand.country})</span>
								{/if}
							</button>
						{/each}
					</div>
				{/if}
			</div>

			<!-- 가격대 -->
			<div class="pt-4 border-t border-[#e5e7eb]">
				<div class="flex items-center justify-between mb-2">
					<label class="text-sm font-semibold text-[#5d4a3f]">가격대</label>
					{#if selectedPriceRange}
						<button
							onclick={() => {
								selectedPriceRange = '';
								handleFilterChange();
							}}
							class="text-xs text-[#bfa094] hover:text-[#a88f84]"
						>
							선택 해제
						</button>
					{/if}
				</div>
				<div class="flex flex-wrap gap-2">
					{#each priceRanges as range}
						<button
							onclick={() => {
								selectedPriceRange = range.value;
								handleFilterChange();
							}}
							class={`px-3 py-1.5 h-9 rounded-md text-sm font-medium transition-all whitespace-nowrap ${
								selectedPriceRange === range.value
									? 'bg-[#7f6251] text-white shadow-sm'
									: 'bg-[#f9fafb] text-[#7f6251] hover:bg-[#f2e8e5] border border-[#e5e7eb]'
							}`}
						>
							{range.label}
						</button>
					{/each}
				</div>
			</div>

			<!-- 평점 필터 -->
			<div class="pt-4 border-t border-[#e5e7eb]">
				<div class="flex items-center justify-between mb-2">
					<label class="text-sm font-semibold text-[#5d4a3f]">평점</label>
					{#if minRating}
						<button
							onclick={() => {
								minRating = null;
								handleFilterChange();
							}}
							class="text-xs text-[#bfa094] hover:text-[#a88f84]"
						>
							선택 해제
						</button>
					{/if}
				</div>
				<div class="flex flex-wrap gap-2">
					{#each ratingOptions as option}
						<button
							onclick={() => {
								minRating = option.value;
								handleFilterChange();
							}}
							class={`px-3 py-1.5 h-9 rounded-md text-sm font-medium transition-all whitespace-nowrap ${
								minRating === option.value
									? 'bg-[#7f6251] text-white shadow-sm'
									: 'bg-[#f9fafb] text-[#7f6251] hover:bg-[#f2e8e5] border border-[#e5e7eb]'
							}`}
						>
							{option.label}
						</button>
					{/each}
				</div>
			</div>
		</div>
	</div>

	<!-- Equipment Grid -->
	{#if loading.equipment}
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
					onclick={loadEquipment}
					class="px-6 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors"
				>
					다시 시도
				</button>
			</div>
		</div>
	{:else if equipment.length === 0}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<div class="text-6xl mb-4">⚙️</div>
				<p class="text-xl font-semibold text-[#5d4a3f] mb-2">데이터가 없습니다</p>
				<p class="text-[#9ca3af] mb-4">
					{#if hasActiveFilters}
						조건에 맞는 장비가 없습니다
					{:else}
						아직 등록된 장비가 없습니다
					{/if}
				</p>
				{#if hasActiveFilters}
					<button
						onclick={clearFilters}
						class="px-6 py-2 text-[#bfa094] border border-[#bfa094] rounded-lg hover:bg-[#f2e8e5] transition-colors"
					>
						전체 장비 보기
					</button>
				{/if}
			</div>
		</div>
	{:else}
		<!-- Grid with more columns (no sidebar) -->
		<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 mb-8">
			{#each equipment as item (item.id)}
				<a
					href="/equipment/{item.id}"
					class="bg-white rounded-lg border border-[#e5e7eb] overflow-hidden hover:shadow-lg transition-all hover:-translate-y-1"
				>
					{#if item.image_url}
						<img
							src={item.image_url}
							alt={item.model}
							class="w-full aspect-square object-cover"
							loading="lazy"
							decoding="async"
						/>
					{:else}
						<div class="w-full aspect-square bg-[#f2e8e5] flex items-center justify-center">
							<span class="text-4xl">☕</span>
						</div>
					{/if}

					<div class="p-3">
						<div class="text-xs font-semibold text-[#bfa094] uppercase tracking-wider mb-1 truncate">
							{item.brand_info.name}
							{#if item.brand_info.country}
								<span class="ml-1 opacity-70">({item.brand_info.country})</span>
							{/if}
						</div>
						<h3 class="text-sm font-semibold text-[#5d4a3f] mb-2 line-clamp-2 min-h-[2.5rem]">
							{item.model}
						</h3>

						{#if item.equipment_category}
							<span
								class="inline-block px-2 py-0.5 bg-[#f2e8e5] text-[#7f6251] text-xs rounded mb-2"
							>
								{item.equipment_category.name}
							</span>
						{/if}

						{#if item.rating}
							<div class="flex items-center text-xs text-[#7f6251] mb-1">
								<span class="mr-1">⭐</span>
								<span class="font-medium">{item.rating.toFixed(1)}</span>
								<span class="text-[#9ca3af] ml-1 text-xs">({item.reviews_count || 0})</span>
							</div>
						{/if}

						{#if item.price_range}
							<div class="text-[#bfa094] font-bold text-sm">{item.price_range}</div>
						{/if}
					</div>
				</a>
			{/each}
		</div>

		<!-- Pagination -->
		{#if totalPages > 1}
			<div class="flex justify-center items-center gap-4 py-8">
				<button
					onclick={prevPage}
					disabled={page === 1}
					class="px-4 py-2 bg-white text-[#7f6251] border border-[#e5e7eb] rounded-lg hover:bg-[#f2e8e5] disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
				>
					← 이전
				</button>
				<span class="text-[#5d4a3f] font-medium min-w-[80px] text-center">
					{page} / {totalPages}
				</span>
				<button
					onclick={nextPage}
					disabled={page === totalPages}
					class="px-4 py-2 bg-white text-[#7f6251] border border-[#e5e7eb] rounded-lg hover:bg-[#f2e8e5] disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
				>
					다음 →
				</button>
			</div>
		{/if}
	{/if}
</div>
