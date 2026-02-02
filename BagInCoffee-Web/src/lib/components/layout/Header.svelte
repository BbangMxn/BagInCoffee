<script lang="ts">
	import { toggleSidebar } from '$lib/stores/ui';
	import Logo from '$lib/components/common/Logo.svelte';
	import type { Session } from '@supabase/supabase-js';
	import type { UserProfile } from '$lib/types/user';

	interface Props {
		session?: Session | null;
		profile?: UserProfile | null;
	}

	let { session = null, profile = null }: Props = $props();
</script>

<header class="bg-white border-b border-[#e5e7eb] fixed top-0 left-0 right-0 z-50">
	<div class="h-14 px-4 flex items-center justify-between">
		<!-- 왼쪽: 햄버거 메뉴 -->
		<button
			class="text-[#7f6251] hover:text-[#5d4a3f] p-2 -ml-2"
			aria-label="메뉴 열기"
			onclick={toggleSidebar}
		>
			<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
			</svg>
		</button>

		<!-- 중앙: 로고 -->
		<a href="/" class="absolute left-1/2 -translate-x-1/2">
			<Logo size="lg" clickable={true} />
		</a>

		<!-- 오른쪽: 알림 또는 로그인 버튼 -->
		<div class="flex items-center">
			{#if session}
				<!-- 로그인된 경우: 알림 아이콘 -->
				<button class="text-[#7f6251] hover:text-[#5d4a3f] relative p-2 -mr-2" aria-label="알림">
					<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
					</svg>
					<span class="absolute top-1 right-1 block h-2 w-2 rounded-full bg-red-500"></span>
				</button>
			{:else}
				<!-- 로그인 안된 경우: 로그인 버튼 -->
				<a
					href="/login"
					class="text-sm font-medium text-[#bfa094] hover:text-[#a18072]"
				>
					로그인
				</a>
			{/if}
		</div>
	</div>
</header>
