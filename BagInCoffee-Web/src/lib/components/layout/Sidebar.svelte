<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { sidebarOpen, closeSidebar } from '$lib/stores/ui';
	import Logo from '$lib/components/common/Logo.svelte';
	import { equipmentApi } from '$lib/api';
	import type { Session } from '@supabase/supabase-js';
	import type { UserProfile } from '$lib/types/user';
	import type { EquipmentCategory } from '$lib/types/equipment';

	interface Props {
		session?: Session | null;
		profile?: UserProfile | null;
	}

	let { session = null, profile = null }: Props = $props();

	let categories = $state<EquipmentCategory[]>([]);
	let loadingCategories = $state(false);
	let showCategories = $state(false); // 카테고리 토글 상태

	async function loadCategories() {
		loadingCategories = true;
		const response = await equipmentApi.getCategories();
		if (response.success && response.data) {
			categories = response.data;
		}
		loadingCategories = false;
	}

	// 전체 장비 페이지에 있을 때 자동으로 카테고리 펼치기
	$effect(() => {
		const pathname = $page.url.pathname;
		if (pathname === '/equipment/all' || pathname.startsWith('/equipment/')) {
			showCategories = true;
		}
	});

	onMount(() => {
		loadCategories();
	});

	interface MenuItem {
		label: string;
		href: string;
		icon: string;
		badge?: { text: string; color: string };
	}

	interface MenuSection {
		title: string;
		items: MenuItem[];
	}

	// 관리자 여부 확인
	const isAdmin = $derived(profile?.role === 'admin');

	const loggedInMenuSections: MenuSection[] = [
		{
			title: '메인',
			items: [
				{
					label: '홈',
					href: '/',
					icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6'
				},
				{
					label: '매거진',
					href: '/magazine',
					icon: 'M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z'
				},
				{
					label: '게시물 작성',
					href: '/create',
					icon: 'M12 4v16m8-8H4'
				},
				{
					label: '내 프로필',
					href: '/profile',
					icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z'
				}
			]
		},
		{
			title: '아카이브',
			items: [
				{
					label: '커피 가이드',
					href: '/guide',
					icon: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253'
				},
				{
					label: '전체 장비',
					href: '/equipment/all',
					icon: 'M4 6h16M4 10h16M4 14h16M4 18h16'
				},
				{
					label: '브랜드별 보기',
					href: '/brands',
					icon: 'M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z'
				}
			]
		},
		{
			title: '커뮤니티',
			items: [
				{
					label: '중고 거래',
					href: '/marketplace',
					icon: 'M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z'
				}
			]
		},
		...(isAdmin ? [{
			title: '관리자',
			items: [
				{
					label: '관리자 홈',
					href: '/admin',
					icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
					badge: { text: 'ADMIN', color: 'red' }
				},
				{
					label: '장비 관리',
					href: '/admin/equipment',
					icon: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z',
					badge: { text: 'NEW', color: 'green' }
				}
			]
		}] : []),
		{
			title: '개발자',
			items: [
				{
					label: '개발자 블로그',
					href: '/developer',
					icon: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4'
				}
			]
		}
	];

	const publicMenuSections: MenuSection[] = [
		{
			title: '메인',
			items: [
				{
					label: '홈',
					href: '/',
					icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6'
				},
				{
					label: '매거진',
					href: '/magazine',
					icon: 'M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z'
				}
			]
		},
		{
			title: '아카이브',
			items: [
				{
					label: '커피 가이드',
					href: '/guide',
					icon: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253'
				},
				{
					label: '전체 장비',
					href: '/equipment/all',
					icon: 'M4 6h16M4 10h16M4 14h16M4 18h16'
				},
				{
					label: '브랜드별 보기',
					href: '/brands',
					icon: 'M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z'
				}
			]
		},
		{
			title: '커뮤니티',
			items: [
				{
					label: '중고 거래',
					href: '/marketplace',
					icon: 'M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z'
				}
			]
		},
		{
			title: '개발자',
			items: [
				{
					label: '개발자 블로그',
					href: '/developer',
					icon: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4'
				}
			]
		}
	];

	function getBadgeClasses(color: string) {
		const classes = {
			yellow: 'bg-yellow-100 text-yellow-800',
			blue: 'bg-blue-100 text-blue-800',
			red: 'bg-red-100 text-red-800',
			green: 'bg-green-100 text-green-800'
		};
		return classes[color as keyof typeof classes] || classes.blue;
	}

	let menuSections = $derived(session ? loggedInMenuSections : publicMenuSections);
</script>

<!-- 오버레이 -->
{#if $sidebarOpen}
	<div
		class="fixed inset-0 bg-black/10 z-40 backdrop-blur-[2px]"
		onclick={closeSidebar}
		role="button"
		tabindex="0"
		aria-label="사이드바 닫기"
	></div>
{/if}

<!-- 사이드바 -->
<aside
	class={`
	fixed left-0 top-0 z-50
	w-80 bg-white h-full border-r border-gray-200 overflow-y-auto
	transition-transform duration-300 ease-in-out
	${$sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
`}
>
	<!-- 헤더 -->
	<div class="h-14 px-4 flex items-center justify-between border-b border-[#e5e7eb]">
		<a href="/" class="flex items-center" onclick={closeSidebar}>
			<Logo size="lg" clickable={true} />
		</a>
		<button
			onclick={closeSidebar}
			class="text-[#7f6251] hover:text-[#5d4a3f] p-2 -mr-2"
			aria-label="닫기"
		>
			<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M6 18L18 6M6 6l12 12"
				/>
			</svg>
		</button>
	</div>

	<!-- 프로필 섹션 (로그인된 경우) 또는 로그인 버튼 (비로그인) -->
	{#if session}
		<a
			href="/profile"
			onclick={closeSidebar}
			class="block p-4 border-b border-[#e5e7eb] bg-gradient-to-r from-[#fdf8f6] to-[#f2e8e5] hover:from-[#f8f0ed] hover:to-[#eaddd7] transition-colors"
		>
			<div class="flex items-center space-x-3">
				{#if profile?.avatar_url}
					<img
						src={profile.avatar_url}
						alt="프로필"
						class="w-14 h-14 rounded-full border-2 border-white shadow-sm object-cover"
					/>
				{:else}
					<div
						class="w-14 h-14 rounded-full bg-[#bfa094] flex items-center justify-center text-white font-bold text-xl border-2 border-white shadow-sm"
					>
						{session.user.email?.charAt(0).toUpperCase()}
					</div>
				{/if}
				<div class="flex-1 min-w-0">
					<p class="text-base font-semibold text-[#5d4a3f] truncate">
						{profile?.full_name || session.user.email?.split('@')[0] || '사용자'}
					</p>
					<p class="text-sm text-[#7f6251] truncate">
						{session.user.email}
					</p>
				</div>
				<svg class="w-5 h-5 text-[#9ca3af]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M9 5l7 7-7 7"
					/>
				</svg>
			</div>
		</a>
	{:else}
		<!-- 비로그인 상태: 로그인 버튼 -->
		<div class="p-4 border-b border-[#e5e7eb] bg-gradient-to-r from-[#fdf8f6] to-[#f2e8e5]">
			<a
				href="/login"
				onclick={closeSidebar}
				class="block w-full py-3 bg-[#bfa094] text-white text-center font-semibold rounded-lg hover:bg-[#a88f84] transition-colors shadow-sm"
			>
				로그인
			</a>
		</div>
	{/if}

	<!-- 메뉴 섹션들 -->
	<nav class="p-4 space-y-1">
		{#each menuSections as section, index}
			<div class={index > 0 ? 'pt-4 pb-2' : 'pb-2'}>
				<p class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
					{section.title}
				</p>
			</div>

			{#each section.items as item}
				<!-- 전체 장비 메뉴는 토글 버튼으로 -->
				{#if item.href === '/equipment/all'}
					<div>
						<button
							onclick={() => showCategories = !showCategories}
							class="w-full flex items-center space-x-3 px-3 py-3 text-[#5d4a3f] hover:bg-[#f2e8e5] hover:text-[#7f6251] rounded-lg transition-colors active:bg-[#eaddd7]"
						>
							<svg
								class="w-5 h-5 flex-shrink-0"
								fill="none"
								stroke="currentColor"
								viewBox="0 0 24 24"
							>
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={item.icon} />
							</svg>
							<span class="font-medium flex-1 text-left">
								{item.label}
							</span>
							{#if !loadingCategories && categories.length > 0}
								<svg
									class={`w-4 h-4 transition-transform ${showCategories ? 'rotate-180' : ''}`}
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
								</svg>
							{/if}
						</button>

						<!-- 카테고리 목록 (토글 가능) -->
						{#if showCategories && !loadingCategories && categories.length > 0}
							<div class="ml-8 mt-1 mb-2 space-y-1">
								<a
									href="/equipment/all"
									class="block px-3 py-2 text-sm text-[#7f6251] hover:bg-[#f9fafb] hover:text-[#5d4a3f] rounded-md transition-colors"
									onclick={(e) => {
										// SPA 방식으로 전환 (페이지 새로고침 방지)
										const currentPath = window.location.pathname;
										if (currentPath === '/equipment/all') {
											e.preventDefault();
											// 카테고리 필터 리셋 이벤트 발생
											window.dispatchEvent(new CustomEvent('reset-category-filter'));
										}
										closeSidebar();
									}}
								>
									전체 장비
								</a>
								{#each categories as category}
									<a
										href="/equipment/all?category_id={category.id}"
										class="block px-3 py-2 text-sm text-[#7f6251] hover:bg-[#f9fafb] hover:text-[#5d4a3f] rounded-md transition-colors"
										onclick={(e) => {
											// SPA 방식으로 전환 (페이지 새로고침 방지)
											const currentPath = window.location.pathname;
											if (currentPath === '/equipment/all') {
												e.preventDefault();
												// 카테고리 선택 이벤트 발생
												window.dispatchEvent(new CustomEvent('select-category', {
													detail: { categoryId: category.id }
												}));
											}
											closeSidebar();
										}}
									>
										{category.name}
									</a>
								{/each}
							</div>
						{/if}
					</div>
				{:else}
					<!-- 다른 메뉴 아이템 -->
					<a
						href={item.href}
						class="flex items-center space-x-3 px-3 py-3 text-[#5d4a3f] hover:bg-[#f2e8e5] hover:text-[#7f6251] rounded-lg transition-colors active:bg-[#eaddd7]"
						onclick={closeSidebar}
					>
						<svg
							class="w-5 h-5 flex-shrink-0"
							fill="none"
							stroke="currentColor"
							viewBox="0 0 24 24"
						>
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={item.icon} />
						</svg>
						<span class="font-medium flex-1">
							{item.label}
						</span>
						{#if item.badge}
							<span
								class={`text-xs font-bold px-2 py-0.5 rounded-full ${getBadgeClasses(item.badge.color)}`}
							>
								{item.badge.text}
							</span>
						{/if}
					</a>
				{/if}
			{/each}
		{/each}

		<!-- 로그아웃 버튼 (로그인된 경우) -->
		{#if session}
			<div class="pt-4"></div>
			<form method="POST" action="/api/auth/logout" class="block">
				<button
					type="submit"
					class="w-full flex items-center space-x-3 px-3 py-3 text-red-600 hover:bg-red-50 rounded-lg transition-colors active:bg-red-100"
				>
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
						/>
					</svg>
					<span class="font-medium">로그아웃</span>
				</button>
			</form>
		{/if}
	</nav>

	<!-- Footer -->
	<div class="p-4 mt-auto border-t border-[#e5e7eb]">
		<p class="text-xs text-center text-[#9ca3af]">
			© 2025 BagInCoffee<br />
			Made with ☕ and 💜
		</p>
	</div>
</aside>
