<script lang="ts">
	import type { Session } from '@supabase/supabase-js';
	import type { UserProfile } from '$lib/types/user';

	interface Props {
		session: Session;
		profile: UserProfile | null;
	}

	let { session, profile }: Props = $props();
</script>

<div class="relative group">
	<button class="flex items-center space-x-2 text-gray-700 hover:text-gray-900">
		{#if profile?.avatar_url}
			<img
				src={profile.avatar_url}
				alt="프로필"
				class="w-8 h-8 rounded-full"
			/>
		{:else}
			<div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-medium text-sm">
				{session.user.email?.charAt(0).toUpperCase()}
			</div>
		{/if}
		<span class="text-sm font-medium hidden md:block">
			{profile?.full_name || session.user.email?.split('@')[0]}
		</span>
		<svg class="w-4 h-4 hidden md:block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
		</svg>
	</button>

	<!-- 드롭다운 메뉴 -->
	<div class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 hidden group-hover:block">
		<div class="px-4 py-2 border-b">
			<p class="text-sm font-medium text-gray-900">
				{profile?.full_name || '사용자'}
			</p>
			<p class="text-xs text-gray-500 truncate">
				{session.user.email}
			</p>
		</div>
		<a href="/profile/edit" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
			프로필 설정
		</a>
		<a href="/settings" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
			계정 설정
		</a>
		<form method="POST" action="/api/auth/logout" class="block">
			<button
				type="submit"
				class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
			>
				로그아웃
			</button>
		</form>
	</div>
</div>
