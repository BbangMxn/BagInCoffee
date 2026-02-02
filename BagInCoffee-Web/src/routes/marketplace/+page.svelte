<script lang="ts">
	import { onMount } from 'svelte';
	import { marketplaceApi } from '$lib/api';
	import type { MarketplaceItemWithSeller } from '$lib/types/marketplace';

	let items: MarketplaceItemWithSeller[] = [];
	let loading = true;
	let error: string | null = null;
	let selectedStatus: 'all' | 'active' | 'reserved' | 'sold' = 'all';
	let page = 1;

	async function loadItems() {
		loading = true;
		error = null;

		const params: any = { page, page_size: 12 };
		if (selectedStatus !== 'all') {
			params.status = selectedStatus;
		}

		const response = await marketplaceApi.getAll(params);

		if (response.success && response.data) {
			items = response.data;
		} else {
			error = response.error?.message || 'Failed to load items';
		}

		loading = false;
	}

	function selectStatus(status: typeof selectedStatus) {
		selectedStatus = status;
		page = 1;
		loadItems();
	}

	function getStatusBadge(status: string) {
		switch (status) {
			case 'active':
				return { text: '판매중', class: 'bg-[#bfa094]' };
			case 'reserved':
				return { text: '예약중', class: 'bg-[#9ca3af]' };
			case 'sold':
				return { text: '판매완료', class: 'bg-red-500' };
			default:
				return { text: status, class: 'bg-gray-500' };
		}
	}

	function formatPrice(price: number): string {
		return new Intl.NumberFormat('ko-KR').format(price) + '원';
	}

	function getTimeAgo(dateString: string): string {
		const date = new Date(dateString);
		const now = new Date();
		const diff = Math.floor((now.getTime() - date.getTime()) / 1000);

		if (diff < 60) return '방금 전';
		if (diff < 3600) return `${Math.floor(diff / 60)}분 전`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}시간 전`;
		if (diff < 604800) return `${Math.floor(diff / 86400)}일 전`;
		return date.toLocaleDateString('ko-KR');
	}

	onMount(() => {
		loadItems();
	});
</script>

<div class="max-w-4xl mx-auto px-4 py-4">
	<div class="flex items-center justify-between mb-6">
		<h1 class="text-2xl font-bold text-[#5d4a3f]">중고 거래</h1>
		<a
			href="/marketplace/create"
			class="px-4 py-2 bg-[#bfa094] text-white rounded-lg text-sm font-medium hover:bg-[#a18072]"
		>
			판매하기
		</a>
	</div>

	<!-- Status Filter -->
	<div class="flex space-x-2 mb-6 overflow-x-auto">
		<button
			on:click={() => selectStatus('all')}
			class="px-4 py-2 rounded-full text-sm whitespace-nowrap {selectedStatus === 'all'
				? 'bg-[#bfa094] text-white'
				: 'bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f2e8e5]'}"
		>
			전체
		</button>
		<button
			on:click={() => selectStatus('active')}
			class="px-4 py-2 rounded-full text-sm whitespace-nowrap {selectedStatus === 'active'
				? 'bg-[#bfa094] text-white'
				: 'bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f2e8e5]'}"
		>
			판매중
		</button>
		<button
			on:click={() => selectStatus('reserved')}
			class="px-4 py-2 rounded-full text-sm whitespace-nowrap {selectedStatus === 'reserved'
				? 'bg-[#bfa094] text-white'
				: 'bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f2e8e5]'}"
		>
			예약중
		</button>
		<button
			on:click={() => selectStatus('sold')}
			class="px-4 py-2 rounded-full text-sm whitespace-nowrap {selectedStatus === 'sold'
				? 'bg-[#bfa094] text-white'
				: 'bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f2e8e5]'}"
		>
			판매완료
		</button>
	</div>

	{#if loading}
		<div class="text-center py-20">
			<p class="text-[#9ca3af] text-lg">로딩중...</p>
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
					on:click={loadItems}
					class="px-6 py-2 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors"
				>
					다시 시도
				</button>
			</div>
		</div>
	{:else if items.length === 0}
		<div class="text-center py-20">
			<div class="inline-block p-8 bg-white rounded-lg border border-[#e5e7eb]">
				<div class="text-6xl mb-4">🛒</div>
				<p class="text-xl font-semibold text-[#5d4a3f] mb-2">데이터가 없습니다</p>
				<p class="text-[#9ca3af] mb-6">
					{#if selectedStatus !== 'all'}
						해당 상태의 상품이 없습니다
					{:else}
						아직 등록된 상품이 없습니다
					{/if}
				</p>
				<a
					href="/marketplace/create"
					class="inline-block px-6 py-3 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] transition-colors font-medium"
				>
					첫 상품 등록하기
				</a>
			</div>
		</div>
	{:else}
		<!-- Product Grid -->
		<div class="grid grid-cols-2 md:grid-cols-3 gap-4">
			{#each items as item (item.id)}
				<a
					href="/marketplace/{item.id}"
					class="bg-white rounded-lg shadow-sm border border-[#e5e7eb] overflow-hidden {item.status ===
					'sold'
						? 'opacity-60'
						: ''}"
				>
					<div class="aspect-square bg-[#f2e8e5] relative">
						{#if item.images && item.images[0]}
							<img src={item.images[0]} alt={item.title} class="w-full h-full object-cover" />
						{/if}
						<span
							class="absolute top-2 left-2 px-2 py-1 text-white text-xs rounded {getStatusBadge(
								item.status
							).class}"
						>
							{getStatusBadge(item.status).text}
						</span>
					</div>
					<div class="p-3">
						<h3 class="text-sm font-semibold text-[#5d4a3f] mb-1 line-clamp-2">
							{item.title}
						</h3>
						<p class="text-lg font-bold text-[#bfa094] mb-2">
							{formatPrice(item.price)}
						</p>
						<div class="flex items-center justify-between text-xs text-[#9ca3af]">
							<span>{item.location || '위치 미상'}</span>
							<span>{getTimeAgo(item.created_at)}</span>
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
