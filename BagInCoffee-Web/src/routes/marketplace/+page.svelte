<script lang="ts">
	import { onMount } from 'svelte';
	import { marketplaceApi } from '$lib/api';
	import type { MarketplaceItemWithSeller } from '$lib/types/marketplace';

	// 포트폴리오용 목업 데이터
	const MOCK_ITEMS: MarketplaceItemWithSeller[] = [
		{
			id: '1',
			title: 'La Marzocco Linea Mini 화이트 (6개월 사용)',
			description: '상태 최상, 박스 및 액세서리 모두 포함',
			price: 4500000,
			status: 'active',
			images: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'],
			location: '서울 강남구',
			created_at: new Date(Date.now() - 1000 * 60 * 30).toISOString(), // 30분 전
			seller: { id: '1', username: 'coffee_lover', avatar_url: null }
		},
		{
			id: '2',
			title: 'Comandante C40 MK4 블랙',
			description: '레드클릭스 포함, 거의 새것',
			price: 280000,
			status: 'active',
			images: ['https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400'],
			location: '경기 성남시',
			created_at: new Date(Date.now() - 1000 * 60 * 60 * 3).toISOString(), // 3시간 전
			seller: { id: '2', username: 'barista_kim', avatar_url: null }
		},
		{
			id: '3',
			title: 'Fellow Ode 그라인더 Gen 2',
			description: '2개월 사용, SSP 버 업그레이드',
			price: 450000,
			status: 'reserved',
			images: ['https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400'],
			location: '서울 마포구',
			created_at: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString(), // 1일 전
			seller: { id: '3', username: 'home_cafe', avatar_url: null }
		},
		{
			id: '4',
			title: 'Hario V60 풀세트 (드립스테이션 포함)',
			description: '드립스테이션, 서버, 드리퍼, 필터 200장',
			price: 85000,
			status: 'active',
			images: ['https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400'],
			location: '부산 해운대구',
			created_at: new Date(Date.now() - 1000 * 60 * 60 * 48).toISOString(), // 2일 전
			seller: { id: '4', username: 'busan_roaster', avatar_url: null }
		},
		{
			id: '5',
			title: 'Acaia Pearl S 스케일',
			description: '케이스 포함, 펌웨어 최신',
			price: 180000,
			status: 'sold',
			images: ['https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400'],
			location: '서울 송파구',
			created_at: new Date(Date.now() - 1000 * 60 * 60 * 72).toISOString(), // 3일 전
			seller: { id: '5', username: 'precision_brew', avatar_url: null }
		},
		{
			id: '6',
			title: 'Breville 870XL 바리스타 익스프레스',
			description: '입문용으로 좋아요, 디스케일링 완료',
			price: 350000,
			status: 'active',
			images: ['https://images.unsplash.com/photo-1534778101976-62847782c213?w=400'],
			location: '인천 연수구',
			created_at: new Date(Date.now() - 1000 * 60 * 60 * 96).toISOString(), // 4일 전
			seller: { id: '6', username: 'coffee_newbie', avatar_url: null }
		}
	];

	let items: MarketplaceItemWithSeller[] = [];
	let loading = true;
	let error: string | null = null;
	let selectedStatus: 'all' | 'active' | 'reserved' | 'sold' = 'all';
	let page = 1;

	async function loadItems() {
		loading = true;
		error = null;

		// 포트폴리오용: 목업 데이터 사용
		await new Promise(r => setTimeout(r, 300));
		
		if (selectedStatus === 'all') {
			items = MOCK_ITEMS;
		} else {
			items = MOCK_ITEMS.filter(item => item.status === selectedStatus);
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
