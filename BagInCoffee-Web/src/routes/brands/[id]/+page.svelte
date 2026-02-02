<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { brandApi, equipmentApi } from '$lib/api';
	import type { BrandWithCategories, EquipmentWithRelations } from '$lib/types/equipment';

	let brand = $state<BrandWithCategories | null>(null);
	let equipment = $state<EquipmentWithRelations[]>([]);
	let loadingBrand = $state(true);
	let loadingEquipment = $state(true);
	let error = $state<string | null>(null);

	const brandId = $derived($page.params.id);

	async function loadBrand() {
		loadingBrand = true;
		error = null;

		const response = await brandApi.getById(brandId);

		if (response.success && response.data) {
			brand = response.data;
		} else {
			error = response.error?.message || '브랜드를 불러오는데 실패했습니다';
		}

		loadingBrand = false;
	}

	async function loadEquipment() {
		loadingEquipment = true;

		const response = await equipmentApi.getAll({
			brand_id: brandId,
			page: 1,
			page_size: 100
		});

		if (response.success && response.data) {
			equipment = response.data.filter(item => item.brand_info !== null);
		}

		loadingEquipment = false;
	}

	onMount(() => {
		loadBrand();
		loadEquipment();
	});
</script>

<div class="max-w-7xl mx-auto px-4 py-6">
	{#if loadingBrand}
		<div class="text-center py-20">
			<p class="text-[#9ca3af] text-lg">로딩 중...</p>
		</div>
	{:else if error}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<p class="text-[#7f6251] mb-2">브랜드를 찾을 수 없습니다</p>
				<p class="text-sm text-[#9ca3af] mb-4">{error}</p>
				<a
					href="/brands"
					class="inline-block px-6 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors"
				>
					브랜드 목록으로
				</a>
			</div>
		</div>
	{:else if brand}
		<!-- Breadcrumb -->
		<div class="mb-4 text-sm text-[#7f6251]">
			<a href="/" class="hover:text-[#5d4a3f]">홈</a>
			<span class="mx-2">→</span>
			<a href="/brands" class="hover:text-[#5d4a3f]">브랜드</a>
			<span class="mx-2">→</span>
			<span class="text-[#5d4a3f] font-medium">{brand.name}</span>
		</div>

		<!-- Brand Header -->
		<div class="bg-white rounded-lg border border-[#e5e7eb] p-8 mb-6">
			<div class="flex flex-col md:flex-row gap-6 items-start">
				{#if brand.logo_url}
					<div class="w-32 h-32 flex-shrink-0 bg-[#f9fafb] rounded-lg border border-[#e5e7eb] p-4">
						<img
							src={brand.logo_url}
							alt={brand.name}
							class="w-full h-full object-contain"
						/>
					</div>
				{/if}
				<div class="flex-1">
					<div class="flex items-center gap-3 mb-2">
						<h1 class="text-3xl font-bold text-[#5d4a3f]">{brand.name}</h1>
						{#if brand.country}
							<span class="px-3 py-1 bg-[#f2e8e5] text-[#7f6251] text-sm font-medium rounded-full">
								{brand.country}
							</span>
						{/if}
					</div>
					{#if brand.name_en}
						<p class="text-lg text-[#9ca3af] mb-4">{brand.name_en}</p>
					{/if}
					{#if brand.description}
						<p class="text-[#7f6251] mb-4">{brand.description}</p>
					{/if}
					<div class="flex flex-wrap gap-4 text-sm">
						{#if brand.founded_year}
							<div class="flex items-center gap-2 text-[#7f6251]">
								<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
								</svg>
								설립: {brand.founded_year}년
							</div>
						{/if}
						{#if brand.website}
							<a
								href={brand.website}
								target="_blank"
								rel="noopener noreferrer"
								class="flex items-center gap-2 text-[#bfa094] hover:text-[#a88f84] transition-colors"
							>
								<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
								</svg>
								웹사이트 방문
							</a>
						{/if}
					</div>
				</div>
			</div>
		</div>

		<!-- Equipment List -->
		<div>
			<div class="flex items-center justify-between mb-4">
				<h2 class="text-2xl font-bold text-[#5d4a3f]">
					{brand.name} 장비
					{#if !loadingEquipment}
						<span class="text-lg font-normal text-[#9ca3af] ml-2">
							({equipment.length}개)
						</span>
					{/if}
				</h2>
			</div>

			{#if loadingEquipment}
				<div class="text-center py-12">
					<p class="text-[#9ca3af]">장비 로딩 중...</p>
				</div>
			{:else if equipment.length === 0}
				<div class="text-center py-12 bg-white rounded-lg border border-[#e5e7eb]">
					<div class="text-4xl mb-3">⚙️</div>
					<p class="text-[#7f6251]">등록된 장비가 없습니다</p>
				</div>
			{:else}
				<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
					{#each equipment as item}
						<a
							href="/equipment/{item.id}"
							class="bg-white rounded-lg border border-[#e5e7eb] overflow-hidden hover:shadow-lg transition-all hover:-translate-y-1"
						>
							{#if item.image_url}
								<img src={item.image_url} alt={item.model} class="w-full aspect-square object-cover" />
							{:else}
								<div class="w-full aspect-square bg-[#f2e8e5] flex items-center justify-center">
									<span class="text-4xl">☕</span>
								</div>
							{/if}

							<div class="p-3">
								<h3 class="text-sm font-semibold text-[#5d4a3f] mb-2 line-clamp-2 min-h-[2.5rem]">
									{item.model}
								</h3>

								{#if item.equipment_category}
									<span class="inline-block px-2 py-0.5 bg-[#f2e8e5] text-[#7f6251] text-xs rounded mb-2">
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
			{/if}
		</div>
	{/if}
</div>
