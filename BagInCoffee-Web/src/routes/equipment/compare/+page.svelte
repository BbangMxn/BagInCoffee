<script lang="ts">
	import type { PageData } from './$types';

	let { data } = $props<{ data: PageData }>();

	let selectedCategory = $state<string>('all');
	let selectedBrand = $state<string>('all');
	let minPrice = $state<number>(0);
	let maxPrice = $state<number>(10000000);
	let sortBy = $state<'price-asc' | 'price-desc' | 'rating' | 'name'>('rating');

	const brands = $derived(data.brands?.map(b => b.name) || []);

	// Filtered and sorted equipment
	const filteredEquipment = $derived(() => {
		let filtered = data.equipment || [];

		// Category filter
		if (selectedCategory !== 'all') {
			filtered = filtered.filter((item) => item.category?.name === selectedCategory);
		}

		// Brand filter
		if (selectedBrand !== 'all') {
			filtered = filtered.filter((item) => item.brand?.name === selectedBrand);
		}

		// Price filter
		filtered = filtered.filter((item) => {
			const price = item.price || 0;
			return price >= minPrice && price <= maxPrice;
		});

		// Sort
		filtered = [...filtered].sort((a, b) => {
			if (sortBy === 'price-asc') return (a.price || 0) - (b.price || 0);
			if (sortBy === 'price-desc') return (b.price || 0) - (a.price || 0);
			if (sortBy === 'rating') return (b.rating || 0) - (a.rating || 0);
			if (sortBy === 'name') return (a.model || '').localeCompare(b.model || '');
			return 0;
		});

		return filtered;
	});

	const categoryName = (catName: string | undefined) => {
		if (!catName) return '';
		if (catName.includes('머신') || catName.includes('Machine')) return '머신';
		if (catName.includes('그라인더') || catName.includes('Grinder')) return '그라인더';
		if (catName.includes('도구') || catName.includes('Tool')) return '추출 도구';
		return catName;
	};

	function resetFilters() {
		selectedCategory = 'all';
		selectedBrand = 'all';
		minPrice = 0;
		maxPrice = 10000000;
		sortBy = 'rating';
	}
</script>

<div class="max-w-7xl mx-auto px-4 py-6">
	<!-- Header -->
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-[#5d4a3f] mb-2">장비 조회</h1>
		<p class="text-[#7f6251]">모든 커피 장비를 한눈에 비교하고 선택하세요</p>
	</div>

	<div class="flex flex-col lg:flex-row gap-6">
		<!-- Filters Sidebar -->
		<div class="lg:w-64 flex-shrink-0">
			<div class="bg-white rounded-lg border border-[#e5e7eb] p-6 sticky top-6">
				<div class="flex items-center justify-between mb-6">
					<h2 class="text-lg font-bold text-[#5d4a3f]">필터</h2>
					<button
						onclick={resetFilters}
						class="text-xs text-[#bfa094] hover:text-[#a18072] uppercase tracking-wider font-semibold"
					>
						초기화
					</button>
				</div>

				<!-- Category Filter -->
				<div class="mb-6">
					<label class="block text-sm font-semibold text-[#5d4a3f] mb-3">카테고리</label>
					<div class="space-y-2">
						<label class="flex items-center cursor-pointer group">
							<input
								type="radio"
								name="category"
								value="all"
								bind:group={selectedCategory}
								class="w-4 h-4 text-[#bfa094] border-[#e5e7eb] focus:ring-[#bfa094]"
							/>
							<span class="ml-2 text-sm text-[#5d4a3f] group-hover:text-[#bfa094]">전체</span>
						</label>
						<label class="flex items-center cursor-pointer group">
							<input
								type="radio"
								name="category"
								value="에스프레소 머신"
								bind:group={selectedCategory}
								class="w-4 h-4 text-[#bfa094] border-[#e5e7eb] focus:ring-[#bfa094]"
							/>
							<span class="ml-2 text-sm text-[#5d4a3f] group-hover:text-[#bfa094]"
								>에스프레소 머신</span
							>
						</label>
						<label class="flex items-center cursor-pointer group">
							<input
								type="radio"
								name="category"
								value="그라인더"
								bind:group={selectedCategory}
								class="w-4 h-4 text-[#bfa094] border-[#e5e7eb] focus:ring-[#bfa094]"
							/>
							<span class="ml-2 text-sm text-[#5d4a3f] group-hover:text-[#bfa094]">그라인더</span>
						</label>
						<label class="flex items-center cursor-pointer group">
							<input
								type="radio"
								name="category"
								value="추출 도구"
								bind:group={selectedCategory}
								class="w-4 h-4 text-[#bfa094] border-[#e5e7eb] focus:ring-[#bfa094]"
							/>
							<span class="ml-2 text-sm text-[#5d4a3f] group-hover:text-[#bfa094]">추출 도구</span>
						</label>
					</div>
				</div>

				<!-- Brand Filter -->
				<div class="mb-6">
					<label class="block text-sm font-semibold text-[#5d4a3f] mb-3">브랜드</label>
					<select
						bind:value={selectedBrand}
						class="w-full px-3 py-2 border border-[#e5e7eb] rounded-lg text-sm text-[#5d4a3f] focus:outline-none focus:ring-2 focus:ring-[#bfa094]"
					>
						<option value="all">전체 브랜드</option>
						{#each brands as brand}
							<option value={brand}>{brand}</option>
						{/each}
					</select>
				</div>

				<!-- Price Range -->
				<div class="mb-6">
					<label class="block text-sm font-semibold text-[#5d4a3f] mb-3">가격 범위</label>
					<div class="space-y-3">
						<div>
							<label class="text-xs text-[#7f6251] mb-1 block">최소</label>
							<input
								type="number"
								bind:value={minPrice}
								step="10000"
								class="w-full px-3 py-2 border border-[#e5e7eb] rounded-lg text-sm text-[#5d4a3f] focus:outline-none focus:ring-2 focus:ring-[#bfa094]"
							/>
						</div>
						<div>
							<label class="text-xs text-[#7f6251] mb-1 block">최대</label>
							<input
								type="number"
								bind:value={maxPrice}
								step="10000"
								class="w-full px-3 py-2 border border-[#e5e7eb] rounded-lg text-sm text-[#5d4a3f] focus:outline-none focus:ring-2 focus:ring-[#bfa094]"
							/>
						</div>
					</div>
				</div>

				<!-- Sort -->
				<div>
					<label class="block text-sm font-semibold text-[#5d4a3f] mb-3">정렬</label>
					<select
						bind:value={sortBy}
						class="w-full px-3 py-2 border border-[#e5e7eb] rounded-lg text-sm text-[#5d4a3f] focus:outline-none focus:ring-2 focus:ring-[#bfa094]"
					>
						<option value="rating">평점 높은 순</option>
						<option value="price-asc">가격 낮은 순</option>
						<option value="price-desc">가격 높은 순</option>
						<option value="name">이름 순</option>
					</select>
				</div>
			</div>
		</div>

		<!-- Equipment List -->
		<div class="flex-1">
			<!-- Results Count -->
			<div class="mb-6 flex items-center justify-between">
				<p class="text-sm text-[#7f6251]">
					총 <span class="font-semibold text-[#5d4a3f]">{filteredEquipment().length}</span>개의 장비
				</p>
			</div>

			<!-- Equipment Grid -->
			{#if filteredEquipment().length > 0}
				<div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
					{#each filteredEquipment() as equipment}
						<a
							href="/equipment/{equipment.id}"
							class="bg-white rounded-lg border border-[#e5e7eb] overflow-hidden hover:shadow-lg transition-shadow group"
						>
							<!-- Image -->
							<div class="aspect-[4/3] bg-[#f5f5f0] relative overflow-hidden">
								<div
									class="absolute inset-0 bg-gradient-to-br from-[#d2bab0]/20 to-[#bfa094]/30 flex items-center justify-center"
								>
									<div class="text-[#bfa094]/30 text-6xl font-light">
										{equipment.brand?.name?.slice(0, 1) || '?'}
									</div>
								</div>
								<div
									class="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity"
								></div>
								<!-- Category Badge -->
								<div class="absolute top-3 left-3">
									<span
										class="bg-white/90 backdrop-blur px-3 py-1 text-xs text-[#7f6251] font-semibold uppercase tracking-wide rounded-full"
									>
										{categoryName(equipment.category?.name)}
									</span>
								</div>
							</div>

							<!-- Content -->
							<div class="p-5">
								<!-- Brand & Rating -->
								<div class="flex items-center justify-between mb-2">
									<span class="text-xs text-[#bfa094] uppercase tracking-wider font-semibold"
										>{equipment.brand?.name || 'Unknown'}</span
									>
									<div class="flex items-center gap-1">
										<svg class="w-4 h-4 text-[#bfa094]" fill="currentColor" viewBox="0 0 20 20">
											<path
												d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
											/>
										</svg>
										<span class="text-sm text-[#5d4a3f] font-medium">{equipment.rating || 0}</span>
									</div>
								</div>

								<!-- Name -->
								<h3
									class="text-lg font-bold text-[#5d4a3f] mb-2 group-hover:text-[#bfa094] transition-colors line-clamp-1"
								>
									{equipment.model || 'Unknown Model'}
								</h3>

								<!-- Description -->
								<p class="text-sm text-[#7f6251] mb-4 line-clamp-2">{equipment.description || ''}</p>

								<!-- Price & Reviews -->
								<div class="flex items-center justify-between pt-4 border-t border-[#e5e7eb]">
									<div>
										{#if equipment.price}
											<span class="text-xl font-bold text-[#bfa094]"
												>{equipment.price.toLocaleString()}원</span
											>
										{:else if equipment.price_range}
											<span class="text-xl font-bold text-[#bfa094]">{equipment.price_range}</span>
										{:else}
											<span class="text-sm text-[#9ca3af]">가격 문의</span>
										{/if}
									</div>
									<span class="text-xs text-[#9ca3af]">리뷰 {equipment.reviews_count || 0}</span>
								</div>
							</div>
						</a>
					{/each}
				</div>
			{:else}
				<div class="text-center py-16 bg-white rounded-lg border border-[#e5e7eb]">
					<p class="text-lg text-[#7f6251] mb-4">필터 조건에 맞는 장비가 없습니다.</p>
					<button
						onclick={resetFilters}
						class="text-[#bfa094] hover:text-[#a18072] font-semibold"
					>
						필터 초기화
					</button>
				</div>
			{/if}
		</div>
	</div>
</div>
