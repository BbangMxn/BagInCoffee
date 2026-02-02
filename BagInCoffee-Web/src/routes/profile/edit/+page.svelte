<script lang="ts">
	import type { PageData, ActionData } from './$types';

	let { data, form }: { data: PageData; form: ActionData } = $props();

	let avatarUrl = $state(data.profile?.avatar_url || 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + data.profile?.id);
	let isUploading = $state(false);
	let uploadError = $state('');

	async function handleAvatarUpload(event: Event) {
		const input = event.target as HTMLInputElement;
		const file = input.files?.[0];

		if (!file) return;

		// 파일 타입 체크
		if (!file.type.startsWith('image/')) {
			uploadError = '이미지 파일만 업로드 가능합니다.';
			return;
		}

		// 파일 크기 체크 (2MB)
		if (file.size > 2 * 1024 * 1024) {
			uploadError = '파일 크기는 2MB 이하여야 합니다.';
			return;
		}

		isUploading = true;
		uploadError = '';

		try {
			const formData = new FormData();
			formData.append('avatar', file);

			const response = await fetch('/api/upload/avatar', {
				method: 'POST',
				body: formData
			});

			const result = await response.json();

			if (!response.ok) {
				throw new Error(result.message || '업로드 실패');
			}

			// 업로드 성공 - 이미지 URL 업데이트
			avatarUrl = result.avatar_url + '?t=' + Date.now(); // 캐시 방지
			uploadError = '';
		} catch (error: any) {
			uploadError = error.message || '이미지 업로드에 실패했습니다.';
		} finally {
			isUploading = false;
		}
	}

	function triggerFileInput() {
		document.getElementById('avatar-input')?.click();
	}
</script>

<!-- 모바일 중심 프로필 수정 페이지 -->
<div class="min-h-screen bg-gray-50">
	<div class="max-w-2xl mx-auto px-4 py-6">
		<!-- 헤더 -->
		<div class="flex items-center justify-between mb-6">
			<a href="/profile" class="text-gray-600 hover:text-gray-900">
				<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
				</svg>
			</a>
			<h1 class="text-xl font-bold text-[#5d4a3f]">프로필 수정</h1>
			<div class="w-6"></div>
		</div>

		<form method="POST" action="?/updateProfile" class="space-y-6">
			<!-- 에러 메시지 -->
			{#if form?.error}
				<div class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl text-sm">
					{form.error}
				</div>
			{/if}

			<!-- 프로필 이미지 업로드 -->
			<div class="flex flex-col items-center space-y-4 pb-6 border-b border-gray-200">
				<div class="relative">
					<img
						src={avatarUrl}
						alt="프로필"
						class="w-24 h-24 rounded-full object-cover border-4 border-white shadow-lg"
					/>
					{#if isUploading}
						<div class="absolute inset-0 flex items-center justify-center bg-black/50 rounded-full">
							<div class="w-8 h-8 border-4 border-white border-t-transparent rounded-full animate-spin"></div>
						</div>
					{/if}
				</div>

				<input
					id="avatar-input"
					type="file"
					accept="image/*"
					onchange={handleAvatarUpload}
					class="hidden"
				/>

				<button
					type="button"
					onclick={triggerFileInput}
					disabled={isUploading}
					class="text-sm text-[#7f6251] hover:text-[#5d4a3f] font-medium disabled:opacity-50 disabled:cursor-not-allowed"
				>
					{isUploading ? '업로드 중...' : '프로필 사진 변경'}
				</button>

				{#if uploadError}
					<p class="text-xs text-red-600">{uploadError}</p>
				{/if}
			</div>

			<!-- 사용자명 -->
			<div>
				<label for="username" class="block text-sm font-medium text-gray-700 mb-1.5">
					사용자명
				</label>
				<input
					type="text"
					id="username"
					name="username"
					value={form?.username || data.profile?.username || ''}
					placeholder="예: coffee_lover"
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
				/>
				<p class="mt-1.5 text-xs text-gray-500">
					다른 사용자가 회원님을 찾을 수 있도록 고유한 사용자명을 설정하세요
				</p>
			</div>

			<!-- 이름 -->
			<div>
				<label for="full_name" class="block text-sm font-medium text-gray-700 mb-1.5">
					이름
				</label>
				<input
					type="text"
					id="full_name"
					name="full_name"
					value={form?.full_name || data.profile?.full_name || ''}
					placeholder="실명 또는 닉네임"
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
				/>
			</div>

			<!-- 이메일 (읽기 전용) -->
			<div>
				<label for="email" class="block text-sm font-medium text-gray-700 mb-1.5">
					이메일
				</label>
				<input
					type="email"
					id="email"
					value={data.session.user.email}
					disabled
					class="w-full px-4 py-3 border border-gray-200 rounded-xl bg-gray-100 text-gray-500 text-sm"
				/>
				<p class="mt-1.5 text-xs text-gray-500">이메일은 변경할 수 없습니다</p>
			</div>

			<!-- 자기소개 -->
			<div>
				<label for="bio" class="block text-sm font-medium text-gray-700 mb-1.5">
					자기소개
				</label>
				<textarea
					id="bio"
					name="bio"
					rows="4"
					value={form?.bio || data.profile?.bio || ''}
					placeholder="자신에 대해 간단히 소개해주세요"
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm resize-none"
				></textarea>
			</div>

			<!-- 위치 -->
			<div>
				<label for="location" class="block text-sm font-medium text-gray-700 mb-1.5">
					위치
				</label>
				<input
					type="text"
					id="location"
					name="location"
					value={form?.location || data.profile?.location || ''}
					placeholder="예: 서울, 대한민국"
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
				/>
			</div>

			<!-- 웹사이트 -->
			<div>
				<label for="website" class="block text-sm font-medium text-gray-700 mb-1.5">
					웹사이트
				</label>
				<input
					type="url"
					id="website"
					name="website"
					value={form?.website || data.profile?.website || ''}
					placeholder="https://example.com"
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
				/>
			</div>

			<!-- 버튼 -->
			<div class="flex gap-3 pt-4">
				<button
					type="submit"
					class="flex-1 py-3.5 px-4 bg-[#7f6251] hover:bg-[#6d5343] active:bg-[#5d4a3f] text-white font-medium rounded-xl transition-colors text-sm shadow-sm"
				>
					저장
				</button>
				<a
					href="/profile"
					class="flex-1 py-3.5 px-4 bg-white border-2 border-gray-300 text-gray-700 hover:bg-gray-50 active:bg-gray-100 font-medium rounded-xl transition-colors text-sm text-center shadow-sm"
				>
					취소
				</a>
			</div>
		</form>
	</div>
</div>
