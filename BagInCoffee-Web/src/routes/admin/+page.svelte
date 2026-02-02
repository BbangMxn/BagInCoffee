<script lang="ts">
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();
</script>

<!-- 관리자 대시보드 -->
<div class="min-h-screen bg-gray-50">
	<!-- 헤더 -->
	<div class="bg-white border-b border-gray-200">
		<div class="max-w-7xl mx-auto px-4 py-6">
			<div class="flex items-center justify-between">
				<div>
					<h1 class="text-2xl font-bold text-[#5d4a3f]">관리자 대시보드</h1>
					<p class="text-sm text-gray-600 mt-1">BagInCoffee 커뮤니티 관리</p>
				</div>
				<a
					href="/profile"
					class="px-4 py-2 text-sm font-medium text-[#7f6251] hover:text-[#5d4a3f]"
				>
					← 프로필로 돌아가기
				</a>
			</div>
		</div>
	</div>

	<div class="max-w-7xl mx-auto px-4 py-6">
		<!-- 통계 카드 -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
			<!-- 총 사용자 -->
			<div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">총 사용자</p>
						<p class="text-3xl font-bold text-[#5d4a3f] mt-2">{data.stats.usersCount}</p>
					</div>
					<div class="bg-[#f8f4f1] rounded-full p-3">
						<svg class="w-6 h-6 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
						</svg>
					</div>
				</div>
			</div>

			<!-- 총 게시물 -->
			<div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">총 게시물</p>
						<p class="text-3xl font-bold text-[#5d4a3f] mt-2">{data.stats.postsCount}</p>
					</div>
					<div class="bg-[#f8f4f1] rounded-full p-3">
						<svg class="w-6 h-6 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
						</svg>
					</div>
				</div>
			</div>

			<!-- 역할 배지 -->
			<div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">내 역할</p>
						<p class="text-xl font-bold text-[#5d4a3f] mt-2 uppercase">{data.profile.role}</p>
					</div>
					<div class="bg-[#f8f4f1] rounded-full p-3">
						<svg class="w-6 h-6 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
						</svg>
					</div>
				</div>
			</div>

			<!-- 활동 상태 -->
			<div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium text-gray-600">상태</p>
						<p class="text-xl font-bold text-green-600 mt-2">활성</p>
					</div>
					<div class="bg-green-50 rounded-full p-3">
						<svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
					</div>
				</div>
			</div>
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
			<!-- 최근 가입 사용자 -->
			<div class="bg-white rounded-xl shadow-sm border border-gray-200">
				<div class="p-6 border-b border-gray-200">
					<h2 class="text-lg font-bold text-[#5d4a3f]">최근 가입 사용자</h2>
				</div>
				<div class="divide-y divide-gray-200">
					{#each data.recentUsers as user}
						<div class="p-4 hover:bg-gray-50 transition-colors">
							<div class="flex items-center space-x-3">
								<img
									src={user.avatar_url || 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + user.id}
									alt={user.full_name || '사용자'}
									class="w-10 h-10 rounded-full object-cover"
								/>
								<div class="flex-1 min-w-0">
									<p class="text-sm font-medium text-gray-900 truncate">
										{user.full_name || '이름 없음'}
									</p>
									<p class="text-xs text-gray-500">
										{user.username ? '@' + user.username : 'ID: ' + user.id.slice(0, 8)}
									</p>
								</div>
								<span class="px-2 py-1 text-xs font-medium rounded-full
									{user.role === 'admin' ? 'bg-red-100 text-red-700' :
									user.role === 'moderator' ? 'bg-blue-100 text-blue-700' :
									'bg-gray-100 text-gray-700'}">
									{user.role}
								</span>
							</div>
						</div>
					{:else}
						<div class="p-8 text-center text-gray-500">
							가입한 사용자가 없습니다
						</div>
					{/each}
				</div>
			</div>

			<!-- 최근 게시물 -->
			<div class="bg-white rounded-xl shadow-sm border border-gray-200">
				<div class="p-6 border-b border-gray-200">
					<h2 class="text-lg font-bold text-[#5d4a3f]">최근 게시물</h2>
				</div>
				<div class="divide-y divide-gray-200">
					{#each data.recentPosts as post}
						<div class="p-4 hover:bg-gray-50 transition-colors">
							<div class="flex space-x-3">
								{#if post.images && post.images.length > 0}
									<img
										src={post.images[0]}
										alt="게시물"
										class="w-16 h-16 rounded object-cover flex-shrink-0"
									/>
								{/if}
								<div class="flex-1 min-w-0">
									<p class="text-sm text-gray-900 line-clamp-2 mb-1">
										{post.content}
									</p>
									<div class="flex items-center space-x-3 text-xs text-gray-500">
										<span>{post.author?.full_name || '익명'}</span>
										<span>❤️ {post.likes_count}</span>
										<span>💬 {post.comments_count}</span>
									</div>
								</div>
							</div>
						</div>
					{:else}
						<div class="p-8 text-center text-gray-500">
							게시물이 없습니다
						</div>
					{/each}
				</div>
			</div>
		</div>

		<!-- 관리 메뉴 -->
		<div class="mt-6 bg-white rounded-xl shadow-sm border border-gray-200 p-6">
			<h2 class="text-lg font-bold text-[#5d4a3f] mb-4">관리 메뉴</h2>
			<div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
				<a
					href="/admin/users"
					class="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-center block"
				>
					<svg class="w-8 h-8 mx-auto mb-2 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
					</svg>
					<span class="text-sm font-medium text-gray-700">사용자 관리</span>
				</a>

				<a
					href="/admin/equipment"
					class="p-4 border-2 border-green-200 bg-green-50 rounded-xl hover:bg-green-100 transition-colors text-center block relative"
				>
					<div class="absolute top-2 right-2">
						<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-600 text-white">
							NEW
						</span>
					</div>
					<svg class="w-8 h-8 mx-auto mb-2 text-green-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
					</svg>
					<span class="text-sm font-medium text-green-900">장비 관리</span>
				</a>

				<a
					href="/admin/brands"
					class="p-4 border-2 border-blue-200 bg-blue-50 rounded-xl hover:bg-blue-100 transition-colors text-center block relative"
				>
					<div class="absolute top-2 right-2">
						<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-600 text-white">
							NEW
						</span>
					</div>
					<svg class="w-8 h-8 mx-auto mb-2 text-blue-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
					</svg>
					<span class="text-sm font-medium text-blue-900">브랜드 관리</span>
				</a>

				<button
					class="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-center"
					disabled
				>
					<svg class="w-8 h-8 mx-auto mb-2 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
					</svg>
					<span class="text-sm font-medium text-gray-700">게시물 관리</span>
					<span class="block text-xs text-gray-500 mt-1">(준비 중)</span>
				</button>

				<button
					class="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-center"
					disabled
				>
					<svg class="w-8 h-8 mx-auto mb-2 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
					</svg>
					<span class="text-sm font-medium text-gray-700">신고 관리</span>
					<span class="block text-xs text-gray-500 mt-1">(준비 중)</span>
				</button>

				<a
					href="/create?type=announcement"
					class="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-center block"
				>
					<svg class="w-8 h-8 mx-auto mb-2 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z" />
					</svg>
					<span class="text-sm font-medium text-gray-700">공지사항 작성</span>
				</a>

				<a
					href="/admin/guides/create"
					class="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-center block"
				>
					<svg class="w-8 h-8 mx-auto mb-2 text-[#7f6251]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
					</svg>
					<span class="text-sm font-medium text-gray-700">커피 가이드 작성</span>
				</a>
			</div>
		</div>
	</div>
</div>
