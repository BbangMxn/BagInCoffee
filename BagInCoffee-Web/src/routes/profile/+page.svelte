<script lang="ts">
	import type { PageData } from './$types';
	import { onMount } from 'svelte';

	let { data }: { data: PageData } = $props();

	let posts = $state<any[]>([]);
	let isLoading = $state(true);

	onMount(async () => {
		// 사용자의 게시물 로드
		try {
			const response = await fetch(`/api/posts?user_id=${data.profile.id}`);
			const result = await response.json();
			if (result.success) {
				posts = result.data;
			}
		} catch (error) {
			console.error('게시물 로드 실패:', error);
		} finally {
			isLoading = false;
		}
	});

	// 기본 프로필 이미지
	const defaultAvatar = 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + data.profile.id;
</script>

<!-- 모바일 중심 프로필 페이지 -->
<div class="min-h-screen bg-gray-50">
	<!-- 프로필 헤더 -->
	<div class="bg-gradient-to-b from-[#f8f4f1] to-white">
		<div class="max-w-2xl mx-auto px-4 py-8">
			<!-- 프로필 이미지와 기본 정보 -->
			<div class="flex flex-col items-center text-center space-y-4">
				<!-- 프로필 이미지 -->
				<div class="relative">
					<img
						src={data.profile.avatar_url || defaultAvatar}
						alt={data.profile.full_name || '프로필'}
						class="w-24 h-24 rounded-full object-cover border-4 border-white shadow-lg"
					/>
				</div>

				<!-- 이름과 사용자명 -->
				<div class="space-y-1">
					<h1 class="text-2xl font-bold text-[#5d4a3f]">
						{data.profile.full_name || '이름 없음'}
					</h1>
					{#if data.profile.username}
						<p class="text-gray-600">@{data.profile.username}</p>
					{/if}
				</div>

				<!-- 자기소개 -->
				{#if data.profile.bio}
					<p class="text-gray-700 max-w-md">
						{data.profile.bio}
					</p>
				{/if}

				<!-- 추가 정보 -->
				<div class="flex flex-wrap justify-center gap-4 text-sm text-gray-600">
					{#if data.profile.location}
						<div class="flex items-center gap-1">
							<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
								/>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
								/>
							</svg>
							<span>{data.profile.location}</span>
						</div>
					{/if}

					{#if data.profile.website}
						<a
							href={data.profile.website}
							target="_blank"
							rel="noopener noreferrer"
							class="flex items-center gap-1 text-[#7f6251] hover:underline"
						>
							<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
								/>
							</svg>
							<span>웹사이트</span>
						</a>
					{/if}
				</div>

				<!-- 프로필 수정 버튼 -->
				<div class="flex gap-3">
					<a
						href="/profile/edit"
						class="px-6 py-2.5 bg-white border-2 border-[#7f6251] text-[#7f6251] rounded-xl font-medium hover:bg-[#f8f4f1] transition-colors text-sm shadow-sm"
					>
						프로필 수정
					</a>

					{#if data.profile.role === 'admin' || data.profile.role === 'moderator'}
						<a
							href="/admin"
							class="px-6 py-2.5 bg-[#7f6251] text-white rounded-xl font-medium hover:bg-[#6d5343] transition-colors text-sm shadow-sm"
						>
							관리자
						</a>
					{/if}
				</div>
			</div>
		</div>
	</div>

	<!-- 통계 -->
	<div class="bg-white border-y border-gray-200">
		<div class="max-w-2xl mx-auto px-4 py-4">
			<div class="grid grid-cols-3 gap-4 text-center">
				<div>
					<div class="text-xl font-bold text-[#5d4a3f]">{posts.length}</div>
					<div class="text-sm text-gray-600">게시물</div>
				</div>
				<div>
					<div class="text-xl font-bold text-[#5d4a3f]">0</div>
					<div class="text-sm text-gray-600">팔로워</div>
				</div>
				<div>
					<div class="text-xl font-bold text-[#5d4a3f]">0</div>
					<div class="text-sm text-gray-600">팔로잉</div>
				</div>
			</div>
		</div>
	</div>

	<!-- 게시물 그리드 -->
	<div class="max-w-2xl mx-auto px-4 py-6">
		<h2 class="text-lg font-bold text-[#5d4a3f] mb-4">게시물</h2>

		{#if isLoading}
			<div class="text-center py-12">
				<div class="inline-block w-8 h-8 border-4 border-[#bfa094] border-t-transparent rounded-full animate-spin"></div>
				<p class="text-gray-600 mt-4">게시물을 불러오는 중...</p>
			</div>
		{:else if posts.length === 0}
			<div class="text-center py-12">
				<svg
					class="w-16 h-16 mx-auto text-gray-400 mb-4"
					fill="none"
					stroke="currentColor"
					viewBox="0 0 24 24"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
					/>
				</svg>
				<p class="text-gray-600">아직 게시물이 없습니다</p>
				<a
					href="/create"
					class="inline-block mt-4 px-4 py-2 bg-[#7f6251] text-white rounded-xl hover:bg-[#6d5343] transition-colors text-sm"
				>
					첫 게시물 작성하기
				</a>
			</div>
		{:else}
			<div class="grid grid-cols-3 gap-1">
				{#each posts as post}
					<a href={`/posts/${post.id}`} class="relative aspect-square bg-gray-100 rounded overflow-hidden">
						{#if post.images && post.images.length > 0}
							<img
								src={post.images[0]}
								alt="게시물"
								class="w-full h-full object-cover hover:opacity-90 transition-opacity"
							/>
							{#if post.images.length > 1}
								<div class="absolute top-2 right-2 bg-black/60 text-white text-xs px-2 py-1 rounded">
									<svg class="w-3 h-3 inline" fill="currentColor" viewBox="0 0 20 20">
										<path
											d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z"
										/>
									</svg>
									{post.images.length}
								</div>
							{/if}
						{:else}
							<div class="w-full h-full flex items-center justify-center bg-gray-200 text-gray-600 p-2 text-xs line-clamp-6">
								{post.content}
							</div>
						{/if}
					</a>
				{/each}
			</div>
		{/if}
	</div>
</div>
