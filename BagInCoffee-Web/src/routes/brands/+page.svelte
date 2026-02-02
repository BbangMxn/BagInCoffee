<script lang="ts">
	import { onMount } from 'svelte';
	import { brandApi } from '$lib/api';
	import type { Brand } from '$lib/types/equipment';

	let brands = $state<Brand[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

	// 국가별 그룹핑
	let brandsByCountry = $derived(() => {
		const grouped = new Map<string, Brand[]>();
		brands.forEach(brand => {
			const country = brand.country || '기타';
			if (!grouped.has(country)) {
				grouped.set(country, []);
			}
			grouped.get(country)!.push(brand);
		});
		return Array.from(grouped.entries()).sort((a, b) => a[0].localeCompare(b[0]));
	});

	async function loadBrands() {
		loading = true;
		error = null;

		const response = await brandApi.getAll();

		if (response.success && response.data) {
			brands = response.data;
		} else {
			error = response.error?.message || '브랜드를 불러오는데 실패했습니다';
		}

		loading = false;
	}

	onMount(() => {
		loadBrands();
	});
</script>

<div class="max-w-7xl mx-auto px-4 py-6">
	<!-- Breadcrumb -->
	<div class="mb-4 text-sm text-[#7f6251]">
		<a href="/" class="hover:text-[#5d4a3f]">홈</a>
		<span class="mx-2">→</span>
		<span class="text-[#5d4a3f] font-medium">브랜드</span>
	</div>

	<!-- Header -->
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-[#5d4a3f] mb-2">브랜드 둘러보기</h1>
		<p class="text-[#7f6251]">커피 장비 브랜드별로 모아보세요</p>
	</div>

	{#if loading}
		<div class="text-center py-20">
			<p class="text-[#9ca3af] text-lg">로딩 중...</p>
		</div>
	{:else if error}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<p class="text-[#7f6251] mb-2">데이터를 불러올 수 없습니다</p>
				<p class="text-sm text-[#9ca3af] mb-4">{error}</p>
				<button
					onclick={loadBrands}
					class="px-6 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors"
				>
					다시 시도
				</button>
			</div>
		</div>
	{:else if brands.length === 0}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<div class="text-6xl mb-4">🏷️</div>
				<p class="text-xl font-semibold text-[#5d4a3f] mb-2">등록된 브랜드가 없습니다</p>
			</div>
		</div>
	{:else}
		<!-- 국가별 브랜드 목록 -->
		<div class="space-y-8">
			{#each brandsByCountry() as [country, countryBrands]}
				<div class="bg-white rounded-lg border border-[#e5e7eb] overflow-hidden">
					<div class="bg-gradient-to-r from-[#fdf8f6] to-[#f9fafb] px-6 py-4 border-b border-[#e5e7eb]">
						<h2 class="text-xl font-bold text-[#5d4a3f]">
							{country}
							<span class="ml-2 text-sm font-normal text-[#9ca3af]">
								({countryBrands.length}개 브랜드)
							</span>
						</h2>
					</div>
					<div class="p-6">
						<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
							{#each countryBrands as brand}
								<a
									href="/brands/{brand.id}"
									class="group block p-4 bg-[#f9fafb] rounded-lg border border-[#e5e7eb] hover:bg-white hover:shadow-md hover:border-[#bfa094] transition-all"
								>
									{#if brand.logo_url}
										<div class="mb-3 h-16 flex items-center justify-center bg-white rounded p-2">
											<img
												src={brand.logo_url}
												alt={brand.name}
												class="max-h-full max-w-full object-contain"
											/>
										</div>
									{/if}
									<h3 class="font-bold text-[#5d4a3f] group-hover:text-[#bfa094] transition-colors mb-1">
										{brand.name}
									</h3>
									{#if brand.name_en}
										<p class="text-sm text-[#9ca3af] mb-2">{brand.name_en}</p>
									{/if}
									{#if brand.description}
										<p class="text-sm text-[#7f6251] line-clamp-2">{brand.description}</p>
									{/if}
								</a>
							{/each}
						</div>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>
