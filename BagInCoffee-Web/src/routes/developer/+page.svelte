<script lang="ts">
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	function formatDate(dateString: string) {
		const date = new Date(dateString);
		return date.toLocaleDateString('ko-KR', {
			year: 'numeric',
			month: 'long',
			day: 'numeric'
		});
	}

	function getUpdateType(content: string): { type: string; color: string; emoji: string } {
		const lowerContent = content.toLowerCase();
		if (lowerContent.includes('신규') || lowerContent.includes('new') || lowerContent.includes('추가')) {
			return { type: '신규 기능', color: 'bg-green-100 text-green-700', emoji: '✨' };
		} else if (lowerContent.includes('수정') || lowerContent.includes('개선') || lowerContent.includes('업데이트')) {
			return { type: '개선', color: 'bg-blue-100 text-blue-700', emoji: '🔧' };
		} else if (lowerContent.includes('버그') || lowerContent.includes('bug') || lowerContent.includes('수정')) {
			return { type: '버그 수정', color: 'bg-red-100 text-red-700', emoji: '🐛' };
		} else if (lowerContent.includes('공지') || lowerContent.includes('알림')) {
			return { type: '공지', color: 'bg-yellow-100 text-yellow-700', emoji: '📢' };
		}
		return { type: '업데이트', color: 'bg-gray-100 text-gray-700', emoji: '📝' };
	}
</script>

<!-- 개발자 페이지 -->
<div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
	<!-- 헤더 -->
	<div class="bg-gradient-to-br from-[#7f6251] via-[#6d5545] to-[#5d4a3f] text-white relative overflow-hidden">
		<!-- 배경 패턴 -->
		<div class="absolute inset-0 opacity-10">
			<svg class="w-full h-full" xmlns="http://www.w3.org/2000/svg">
				<pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
					<circle cx="20" cy="20" r="1" fill="currentColor" />
				</pattern>
				<rect width="100%" height="100%" fill="url(#grid)" />
			</svg>
		</div>

		<div class="max-w-5xl mx-auto px-4 py-16 relative">
			<div class="flex items-center justify-between">
				<div>
					<div class="flex items-center gap-3 mb-3">
						<div class="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center">
							<svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
							</svg>
						</div>
						<h1 class="text-4xl font-bold">개발자 블로그</h1>
					</div>
					<p class="text-white/90 text-lg">BagInCoffee의 최신 업데이트와 기술 소식</p>
				</div>
				<a
					href="/"
					class="px-5 py-2.5 bg-white/15 hover:bg-white/25 rounded-xl text-sm font-medium transition-all backdrop-blur-sm border border-white/20 hover:border-white/30"
				>
					← 홈으로
				</a>
			</div>
		</div>
	</div>

	<div class="max-w-5xl mx-auto px-4 py-12">
		<!-- 공지사항 목록 -->
		<div class="space-y-8">
			{#if data.announcements.length === 0}
				<!-- 공지사항 없음 -->
				<div class="bg-white rounded-2xl shadow-lg border border-gray-200 p-16 text-center">
					<div class="text-gray-300 mb-6">
						<svg class="w-20 h-20 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
						</svg>
					</div>
					<p class="text-gray-700 font-semibold text-lg mb-2">아직 공지사항이 없습니다</p>
					<p class="text-sm text-gray-500">곧 새로운 업데이트 소식을 전해드릴게요!</p>
				</div>
			{:else}
				{#each data.announcements as announcement}
					{@const updateInfo = getUpdateType(announcement.content)}
					{@const profile = Array.isArray(announcement.profiles) ? announcement.profiles[0] : announcement.profiles}
					<article class="group bg-white rounded-2xl shadow-md border border-gray-200/80 overflow-hidden hover:shadow-xl hover:border-gray-300 transition-all duration-300">
						<!-- 상태 바 -->
						<div class="h-1.5 bg-gradient-to-r from-[#7f6251] to-[#5d4a3f]"></div>

						<!-- 헤더 -->
						<div class="p-8">
							<div class="flex items-start justify-between mb-6">
								<div class="flex items-center gap-4">
									{#if profile}
										<div class="relative">
											<img
												src={profile.avatar_url || 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + profile.id}
												alt={profile.full_name || '개발자'}
												class="w-12 h-12 rounded-full object-cover ring-2 ring-gray-100"
											/>
											<div class="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 rounded-full border-2 border-white"></div>
										</div>
										<div>
											<div class="flex items-center gap-2 mb-1">
												<p class="font-semibold text-gray-900 text-lg">{profile.full_name || '개발팀'}</p>
												{#if profile.role === 'admin'}
													<span class="px-2.5 py-0.5 bg-gradient-to-r from-red-500 to-red-600 text-white text-xs font-semibold rounded-full">
														관리자
													</span>
												{/if}
											</div>
											<p class="text-sm text-gray-500 flex items-center gap-1">
												<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
												</svg>
												{formatDate(announcement.created_at)}
											</p>
										</div>
									{/if}
								</div>
								<span class="px-4 py-1.5 {updateInfo.color} text-sm font-semibold rounded-full shadow-sm">
									{updateInfo.emoji} {updateInfo.type}
								</span>
							</div>

							<!-- 본문 -->
							<div class="prose prose-base max-w-none">
								<p class="text-gray-700 leading-relaxed whitespace-pre-wrap text-[15px]">{announcement.content}</p>
							</div>

							<!-- 이미지 -->
							{#if announcement.images && announcement.images.length > 0}
								<div class="mt-6 grid {announcement.images.length === 1 ? 'grid-cols-1' : 'grid-cols-2'} gap-4">
									{#each announcement.images as image}
										<div class="relative overflow-hidden rounded-xl group/image">
											<img
												src={image}
												alt="업데이트 이미지"
												class="w-full h-64 object-cover group-hover/image:scale-105 transition-transform duration-300 cursor-pointer"
											/>
											<div class="absolute inset-0 bg-black/0 group-hover/image:bg-black/10 transition-colors duration-300"></div>
										</div>
									{/each}
								</div>
							{/if}
						</div>

						<!-- 푸터 -->
						<div class="px-8 py-4 bg-gradient-to-br from-gray-50 to-gray-100/50 border-t border-gray-100">
							<div class="flex items-center justify-between text-xs text-gray-500">
								<div class="flex items-center gap-1">
									<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
									</svg>
									<span>게시일: {formatDate(announcement.created_at)}</span>
								</div>
								{#if announcement.updated_at !== announcement.created_at}
									<div class="flex items-center gap-1">
										<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
										</svg>
										<span>수정일: {formatDate(announcement.updated_at)}</span>
									</div>
								{/if}
							</div>
						</div>
					</article>
				{/each}
			{/if}
		</div>

		<!-- 개발팀 연락처 -->
		<div class="mt-12 bg-gradient-to-br from-white to-gray-50 rounded-2xl shadow-lg border border-gray-200 p-10 text-center">
			<div class="mb-4">
				<div class="w-16 h-16 bg-gradient-to-br from-[#7f6251] to-[#5d4a3f] rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
					<svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
					</svg>
				</div>
			</div>
			<h3 class="text-xl font-bold text-gray-900 mb-2">문의사항이 있으신가요?</h3>
			<p class="text-gray-600 mb-4">기술 지원, 버그 제보, 제안 사항 등 언제든지 연락주세요.</p>
			<a
				href="mailto:dev@bagincoffee.com"
				class="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-[#7f6251] to-[#5d4a3f] text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300 hover:scale-105"
			>
				<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
				</svg>
				dev@bagincoffee.com
			</a>
		</div>
	</div>

	<!-- Footer 공간 -->
	<div class="h-12"></div>
</div>
