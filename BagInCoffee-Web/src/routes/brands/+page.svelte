<script lang="ts">
	import { onMount } from 'svelte';
	import { brandApi } from '$lib/api';
	import type { Brand } from '$lib/types/equipment';

	// 포트폴리오용 목업 데이터
	const MOCK_BRANDS: Brand[] = [
		// 이탈리아
		{ id: '1', name: 'La Marzocco', name_en: 'La Marzocco', country: '이탈리아', description: '1927년 설립된 프리미엄 에스프레소 머신 제조사', logo_url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/La_Marzocco_logo.svg/200px-La_Marzocco_logo.svg.png' },
		{ id: '2', name: 'Nuova Simonelli', name_en: 'Nuova Simonelli', country: '이탈리아', description: '월드 바리스타 챔피언십 공식 후원사', logo_url: null },
		{ id: '3', name: 'Rocket Espresso', name_en: 'Rocket Espresso', country: '이탈리아', description: '밀라노의 프리미엄 에스프레소 머신', logo_url: null },
		{ id: '4', name: 'ECM', name_en: 'ECM Manufacture', country: '이탈리아', description: '독일 정밀 공학과 이탈리안 디자인의 조화', logo_url: null },
		// 독일
		{ id: '5', name: 'Mahlkönig', name_en: 'Mahlkönig', country: '독일', description: '전문가용 그라인더의 대명사', logo_url: null },
		{ id: '6', name: 'Comandante', name_en: 'Comandante', country: '독일', description: '프리미엄 수동 그라인더', logo_url: null },
		// 미국
		{ id: '7', name: 'Baratza', name_en: 'Baratza', country: '미국', description: '가정용 그라인더 전문 브랜드', logo_url: null },
		{ id: '8', name: 'Fellow', name_en: 'Fellow', country: '미국', description: '디자인과 기능을 겸비한 커피 도구', logo_url: null },
		// 일본
		{ id: '9', name: 'Hario', name_en: 'Hario', country: '일본', description: 'V60의 창시자, 유리 제품 전문 기업', logo_url: null },
		{ id: '10', name: 'Kalita', name_en: 'Kalita', country: '일본', description: '웨이브 드리퍼로 유명한 커피 도구 브랜드', logo_url: null },
		// 한국
		{ id: '11', name: '제니스', name_en: 'Xeoleo', country: '한국', description: '합리적인 가격의 가정용 그라인더', logo_url: null },
		{ id: '12', name: '테라로사', name_en: 'Terarosa', country: '한국', description: '강릉의 스페셜티 커피 브랜드', logo_url: null },
	];

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

		// 포트폴리오용: 목업 데이터 사용
		await new Promise(r => setTimeout(r, 300));
		brands = MOCK_BRANDS;
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
