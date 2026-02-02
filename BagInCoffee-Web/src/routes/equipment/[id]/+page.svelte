<script lang="ts">
	import type { PageData } from './$types';
	import { goto } from '$app/navigation';

	let { data }: { data: PageData } = $props();

	const equipment = $derived(data.equipment);
	const reviews = $derived(data.reviews);
	const reviewCount = $derived(data.reviewCount);

	// 평균 평점 계산
	const averageRating = $derived(equipment?.rating || 0);
	const ratingStars = $derived(Math.round(averageRating));

	// specs를 객체로 파싱 (JSON 형태일 경우)
	const specs = $derived(() => {
		if (!equipment?.specs) return {};
		if (typeof equipment.specs === 'object') return equipment.specs;
		try {
			return JSON.parse(equipment.specs);
		} catch {
			return {};
		}
	});

	// purchase_links를 객체로 파싱 (JSON 형태일 경우)
	const purchaseLinks = $derived(() => {
		if (!equipment?.purchase_links) return {};
		if (typeof equipment.purchase_links === 'object') return equipment.purchase_links;
		try {
			return JSON.parse(equipment.purchase_links);
		} catch {
			return {};
		}
	});

	// 쇼핑몰 정보 매핑
	const shopInfo: Record<string, { name: string; color: string; icon?: string }> = {
		naver: { name: '네이버 쇼핑', color: 'bg-[#03C75A] hover:bg-[#02B350]' },
		coupang: { name: '쿠팡', color: 'bg-[#FF6B00] hover:bg-[#E66000]' },
		amazon: { name: '아마존', color: 'bg-[#FF9900] hover:bg-[#E68900]' },
		official: { name: '공식 사이트', color: 'bg-gradient-to-r from-[#7f6251] to-[#5d4a3f] hover:opacity-90' }
	};

	// 날짜 포맷팅
	function formatDate(dateString: string) {
		const date = new Date(dateString);
		return date.toLocaleDateString('ko-KR', {
			year: 'numeric',
			month: 'long',
			day: 'numeric'
		});
	}

	// 상대 시간 포맷팅
	function formatRelativeTime(dateString: string) {
		const date = new Date(dateString);
		const now = new Date();
		const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

		if (diffInSeconds < 60) return '방금 전';
		if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}분 전`;
		if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}시간 전`;
		if (diffInSeconds < 2592000) return `${Math.floor(diffInSeconds / 86400)}일 전`;
		if (diffInSeconds < 31536000) return `${Math.floor(diffInSeconds / 2592000)}개월 전`;
		return `${Math.floor(diffInSeconds / 31536000)}년 전`;
	}
</script>

{#if equipment}
	<!-- Hero Section -->
	<div class="bg-gradient-to-br from-gray-50 to-gray-100">
		<div class="max-w-7xl mx-auto px-4 py-8">
			<!-- Breadcrumb -->
			<nav class="flex items-center gap-2 text-sm text-gray-500 mb-6">
				<a href="/" class="hover:text-[#7f6251] transition-colors">홈</a>
				<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
				</svg>
				<a href="/equipment/all" class="hover:text-[#7f6251] transition-colors">전체 장비</a>
				{#if equipment.equipment_category}
					<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M9 5l7 7-7 7"
						/>
					</svg>
					<a
						href="/equipment/all?category={equipment.equipment_category.id}"
						class="hover:text-[#7f6251] transition-colors"
					>
						{equipment.equipment_category.name}
					</a>
				{/if}
				<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
				</svg>
				<span class="text-gray-900 font-medium">{equipment.model}</span>
			</nav>

			<!-- Main Content -->
			<div class="grid lg:grid-cols-2 gap-12 mb-12">
				<!-- Image Section -->
				<div class="space-y-4">
					<div class="bg-white rounded-2xl shadow-lg overflow-hidden aspect-square flex items-center justify-center relative group">
						{#if equipment.image_url}
							<img
								src={equipment.image_url}
								alt={equipment.model}
								class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
							/>
						{:else}
							<!-- 플레이스홀더 -->
							<div class="absolute inset-0 bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center">
								<div class="text-center">
									{#if equipment.brand_info?.logo_url}
										<img
											src={equipment.brand_info.logo_url}
											alt={equipment.brand_info.name}
											class="w-32 h-32 object-contain opacity-30 mx-auto mb-4"
											loading="lazy"
											decoding="async"
										/>
									{/if}
									<p class="text-6xl font-bold text-gray-300">
										{equipment.brand?.slice(0, 1) || '?'}
									</p>
								</div>
							</div>
						{/if}
					</div>
				</div>

				<!-- Info Section -->
				<div class="space-y-6">
					<!-- Brand Badge -->
					{#if equipment.brand_info}
						<a
							href="/brands/{equipment.brand_info.id}"
							class="inline-flex items-center gap-3 px-4 py-2 bg-white rounded-xl shadow-sm hover:shadow-md transition-all group"
						>
							{#if equipment.brand_info.logo_url}
								<img
									src={equipment.brand_info.logo_url}
									alt={equipment.brand_info.name}
									class="w-8 h-8 object-contain"
									loading="lazy"
									decoding="async"
								/>
							{/if}
							<div>
								<p class="text-xs text-gray-500">브랜드</p>
								<p class="font-semibold text-gray-900 group-hover:text-[#7f6251] transition-colors">
									{equipment.brand_info.name}
								</p>
							</div>
							{#if equipment.brand_info.country}
								<span class="ml-auto px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full">
									{equipment.brand_info.country}
								</span>
							{/if}
						</a>
					{:else if equipment.brand}
						<div class="inline-block px-4 py-2 bg-white rounded-xl shadow-sm">
							<p class="text-xs text-gray-500">브랜드</p>
							<p class="font-semibold text-gray-900">{equipment.brand}</p>
						</div>
					{/if}

					<!-- Title -->
					<div>
						<h1 class="text-4xl font-bold text-gray-900 mb-2">{equipment.model}</h1>
						{#if equipment.equipment_category}
							<p class="text-lg text-gray-600 flex items-center gap-2">
								{#if equipment.equipment_category.icon}
									<span>{equipment.equipment_category.icon}</span>
								{/if}
								{equipment.equipment_category.name}
							</p>
						{/if}
					</div>

					<!-- Rating -->
					{#if averageRating > 0}
						<div class="flex items-center gap-4">
							<div class="flex items-center gap-1">
								{#each Array(5) as _, i}
									<svg
										class="w-6 h-6 {i < ratingStars ? 'text-yellow-400' : 'text-gray-300'}"
										fill="currentColor"
										viewBox="0 0 20 20"
									>
										<path
											d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
										/>
									</svg>
								{/each}
							</div>
							<div class="text-lg">
								<span class="font-bold text-gray-900">{averageRating.toFixed(1)}</span>
								<span class="text-gray-500">
									({equipment.reviews_count || 0}개 리뷰)
								</span>
							</div>
						</div>
					{/if}

					<!-- Price -->
					{#if equipment.price_range}
						<div class="bg-gradient-to-br from-[#7f6251] to-[#5d4a3f] rounded-2xl p-6 text-white shadow-xl">
							<p class="text-sm opacity-90 mb-1">가격대</p>
							<p class="text-3xl font-bold">{equipment.price_range}</p>
						</div>
					{/if}

					<!-- Description -->
					{#if equipment.description}
						<div class="prose prose-lg max-w-none">
							<p class="text-gray-700 leading-relaxed">{equipment.description}</p>
						</div>
					{/if}

					<!-- Purchase Links - 눈에 띄게 -->
					{#if purchaseLinks() && Object.keys(purchaseLinks()).length > 0}
						<div class="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl p-6 border-2 border-blue-200 shadow-lg">
							<div class="flex items-center gap-2 mb-4">
								<div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl flex items-center justify-center shadow-md">
									<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
									</svg>
								</div>
								<div>
									<h3 class="text-lg font-bold text-gray-900">온라인 구매</h3>
									<p class="text-sm text-gray-600">신뢰할 수 있는 쇼핑몰에서 구매하세요</p>
								</div>
							</div>
							<div class="grid grid-cols-1 gap-3">
								{#each Object.entries(purchaseLinks()) as [shop, url]}
									{#if url}
										<a
											href={url}
											target="_blank"
											rel="noopener noreferrer"
											class="flex items-center justify-between px-5 py-4 {shopInfo[shop]?.color || 'bg-gray-600 hover:bg-gray-700'} text-white rounded-xl font-semibold transition-all shadow-md hover:shadow-xl hover:scale-[1.02] group"
										>
											<div class="flex items-center gap-3">
												<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
												</svg>
												<span>{shopInfo[shop]?.name || shop}에서 구매</span>
											</div>
											<svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
											</svg>
										</a>
									{/if}
								{/each}
							</div>
						</div>
					{/if}

					<!-- Actions -->
					<div class="flex gap-3 pt-4">
						<button
							class="flex-1 px-6 py-3.5 border-2 border-[#7f6251] text-[#7f6251] font-semibold rounded-xl hover:bg-[#7f6251] hover:text-white transition-all duration-300 flex items-center justify-center gap-2"
						>
							<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
								/>
							</svg>
							<span>위시리스트</span>
						</button>
						<button
							class="px-6 py-3.5 border-2 border-gray-300 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition-all duration-300"
						>
							<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"
								/>
							</svg>
						</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Details Section -->
	<div class="max-w-7xl mx-auto px-4 py-12 space-y-8">
		<!-- Specifications -->
		{#if specs() && Object.keys(specs()).length > 0}
			<div class="bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden">
				<div class="bg-gradient-to-r from-gray-50 to-gray-100 px-8 py-6 border-b border-gray-200">
					<h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
						<svg class="w-7 h-7 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"
							/>
						</svg>
						제품 사양
					</h2>
				</div>
				<div class="p-8">
					<div class="grid md:grid-cols-2 gap-6">
						{#each Object.entries(specs()) as [key, value]}
							<div class="flex items-start gap-4 p-4 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors">
								<div class="w-2 h-2 rounded-full bg-[#7f6251] mt-2 flex-shrink-0"></div>
								<div class="flex-1">
									<p class="text-sm font-medium text-gray-500 mb-1">{key}</p>
									<p class="text-base font-semibold text-gray-900">{value}</p>
								</div>
							</div>
						{/each}
					</div>
				</div>
			</div>
		{/if}

		<!-- Reviews Section -->
		<div class="bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden">
			<div class="bg-gradient-to-r from-gray-50 to-gray-100 px-8 py-6 border-b border-gray-200">
				<div class="flex items-center justify-between">
					<h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
						<svg class="w-7 h-7 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
							/>
						</svg>
						사용자 리뷰
					</h2>
					<span class="px-4 py-2 bg-[#7f6251] text-white rounded-full text-sm font-semibold">
						{reviewCount}개
					</span>
				</div>
			</div>

			<div class="p-8">
				{#if reviews && reviews.length > 0}
					<div class="space-y-6">
						{#each reviews as review}
							<div class="p-6 border border-gray-200 rounded-xl hover:shadow-md transition-shadow">
								<div class="flex items-start justify-between mb-4">
									<div class="flex items-center gap-3">
										{#if review.author?.avatar_url}
											<img
												src={review.author.avatar_url}
												alt={review.author.full_name || review.author.username}
												class="w-12 h-12 rounded-full object-cover ring-2 ring-gray-100"
												loading="lazy"
												decoding="async"
											/>
										{:else}
											<div class="w-12 h-12 rounded-full bg-gradient-to-br from-[#7f6251] to-[#5d4a3f] flex items-center justify-center text-white font-bold">
												{review.author?.full_name?.slice(0, 1) || review.author?.username?.slice(0, 1) || 'U'}
											</div>
										{/if}
										<div>
											<p class="font-semibold text-gray-900">
												{review.author?.full_name || review.author?.username || '익명'}
											</p>
											<p class="text-sm text-gray-500">{formatRelativeTime(review.created_at)}</p>
										</div>
									</div>
									<div class="flex items-center gap-1">
										{#each Array(5) as _, i}
											<svg
												class="w-5 h-5 {i < review.rating ? 'text-yellow-400' : 'text-gray-300'}"
												fill="currentColor"
												viewBox="0 0 20 20"
											>
												<path
													d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
												/>
											</svg>
										{/each}
									</div>
								</div>
								<p class="text-gray-700 leading-relaxed">{review.review}</p>
							</div>
						{/each}
					</div>
				{:else}
					<div class="text-center py-12">
						<svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
							/>
						</svg>
						<p class="text-gray-600 font-medium mb-2">아직 리뷰가 없습니다</p>
						<p class="text-sm text-gray-500">첫 번째 리뷰를 작성해보세요!</p>
					</div>
				{/if}
			</div>
		</div>
	</div>
{:else}
	<div class="min-h-screen flex items-center justify-center bg-gray-50">
		<div class="text-center">
			<svg class="w-24 h-24 text-gray-300 mx-auto mb-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
				/>
			</svg>
			<h1 class="text-2xl font-bold text-gray-900 mb-2">장비를 찾을 수 없습니다</h1>
			<p class="text-gray-600 mb-8">요청하신 장비 정보가 존재하지 않습니다.</p>
			<button
				onclick={() => goto('/equipment/all')}
				class="px-6 py-3 bg-gradient-to-r from-[#7f6251] to-[#5d4a3f] text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300"
			>
				전체 장비 보기
			</button>
		</div>
	</div>
{/if}
