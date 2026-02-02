<script lang="ts">
	import type { ActionData } from './$types';
	import Logo from '$lib/components/common/Logo.svelte';

	let { form }: { form: ActionData } = $props();

	let avatarPreview = $state<string | null>(null);

	function handleAvatarSelect(e: Event) {
		const target = e.target as HTMLInputElement;
		const file = target.files?.[0];

		if (file) {
			// 파일 크기 체크 (5MB)
			if (file.size > 5 * 1024 * 1024) {
				alert('파일 크기는 5MB 이하여야 합니다.');
				target.value = '';
				return;
			}

			// 이미지 미리보기
			const reader = new FileReader();
			reader.onload = (e) => {
				avatarPreview = e.target?.result as string;
			};
			reader.readAsDataURL(file);
		}
	}
</script>

<!-- 모바일 중심 회원가입 페이지 -->
<div class="min-h-screen bg-gradient-to-b from-[#f8f4f1] to-white flex flex-col">
	<!-- 로고 섹션 -->
	<div class="flex-1 flex flex-col items-center justify-center px-6 pt-12 pb-6">
		<div class="w-full max-w-sm space-y-8">
			<!-- 로고 -->
			<div class="text-center space-y-4">
				<Logo size="2xl" class="justify-center" />
				<h1 class="text-2xl font-bold text-[#5d4a3f]">커피 애호가들의 공간</h1>
				<p class="text-sm text-gray-600">BagInCoffee에 가입하세요</p>
			</div>

			<!-- 성공 메시지 -->
			{#if form?.success}
				<div class="bg-green-50 border border-green-200 text-green-600 px-4 py-3 rounded-xl text-sm">
					회원가입 성공! 이메일을 확인해주세요.
				</div>
			{/if}

			<!-- 에러 메시지 -->
			{#if form?.error}
				<div class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl text-sm">
					{form.error}
				</div>
			{/if}

			<!-- 소셜 회원가입 버튼들 -->
			<div class="space-y-3">
				<!-- Google 회원가입 -->
				<form method="POST" action="?/google">
					<button
						type="submit"
						class="w-full flex items-center justify-center gap-3 px-4 py-3.5 border border-gray-200 rounded-xl shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 active:bg-gray-100 transition-colors"
					>
						<svg class="w-5 h-5" viewBox="0 0 24 24">
							<path
								fill="#4285F4"
								d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
							/>
							<path
								fill="#34A853"
								d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
							/>
							<path
								fill="#FBBC05"
								d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
							/>
							<path
								fill="#EA4335"
								d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
							/>
						</svg>
						<span>Google로 가입하기</span>
					</button>
				</form>

				<!-- Kakao 회원가입 -->
				<form method="POST" action="?/kakao">
					<button
						type="submit"
						class="w-full flex items-center justify-center gap-3 px-4 py-3.5 rounded-xl shadow-sm text-sm font-medium text-gray-900 hover:opacity-90 active:opacity-80 transition-opacity"
						style="background-color: #FEE500;"
					>
						<svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
							<path
								d="M12 3C6.477 3 2 6.477 2 10.75c0 2.67 1.666 5.01 4.205 6.505-.172.63-.617 2.345-.707 2.707-.11.446.165.44.349.32.147-.096 2.311-1.565 3.288-2.227.621.086 1.26.13 1.915.13 5.523 0 10-3.477 10-7.75S17.523 3 12 3z"
							/>
						</svg>
						<span>카카오로 가입하기</span>
					</button>
				</form>

				<!-- GitHub 회원가입 -->
				<form method="POST" action="?/github">
					<button
						type="submit"
						class="w-full flex items-center justify-center gap-3 px-4 py-3.5 rounded-xl shadow-sm bg-[#24292e] text-sm font-medium text-white hover:bg-[#1b1f23] active:bg-[#15181b] transition-colors"
					>
						<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
							<path
								d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"
							/>
						</svg>
						<span>GitHub로 가입하기</span>
					</button>
				</form>
			</div>

			<!-- 구분선 -->
			<div class="relative">
				<div class="absolute inset-0 flex items-center">
					<div class="w-full border-t border-gray-200"></div>
				</div>
				<div class="relative flex justify-center text-xs">
					<span class="px-3 bg-gradient-to-b from-[#f8f4f1] to-white text-gray-500">또는</span>
				</div>
			</div>

			<!-- 이메일/비밀번호 회원가입 폼 -->
			<form class="space-y-4" method="POST" action="?/signup" enctype="multipart/form-data">
				<div class="space-y-3">
					<!-- 프로필 사진 -->
					<div class="flex flex-col items-center pb-4 border-b border-gray-200">
						<label for="avatar" class="block text-sm font-medium text-gray-700 mb-3 text-center">
							프로필 사진
						</label>
						<div class="relative">
							{#if avatarPreview}
								<img
									src={avatarPreview}
									alt="프로필 미리보기"
									class="w-24 h-24 rounded-full object-cover border-2 border-[#bfa094]"
								/>
							{:else}
								<div class="w-24 h-24 rounded-full bg-[#f2e8e5] flex items-center justify-center border-2 border-[#bfa094]">
									<svg
										class="w-12 h-12 text-[#bfa094]"
										fill="none"
										stroke="currentColor"
										viewBox="0 0 24 24"
									>
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
										/>
									</svg>
								</div>
							{/if}
							<label
								for="avatar"
								class="absolute bottom-0 right-0 w-8 h-8 bg-[#7f6251] rounded-full flex items-center justify-center cursor-pointer hover:bg-[#6d5343] transition-colors"
							>
								<svg
									class="w-4 h-4 text-white"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
									/>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
									/>
								</svg>
							</label>
						</div>
						<input
							id="avatar"
							name="avatar"
							type="file"
							accept="image/*"
							onchange={handleAvatarSelect}
							class="hidden"
						/>
						<p class="text-xs text-gray-500 mt-2 text-center">
							선택사항 (최대 5MB)
						</p>
					</div>

					<div>
						<label for="username" class="block text-sm font-medium text-gray-700 mb-1.5">
							닉네임 <span class="text-red-500">*</span>
						</label>
						<input
							id="username"
							name="username"
							type="text"
							required
							pattern="^[a-zA-Z0-9_가-힣]&#123;2,20&#125;$"
							value={form?.username || ''}
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="커피러버"
						/>
						<p class="mt-1 text-xs text-gray-500">
							2-20자, 한글/영문/숫자/언더스코어 사용 가능
						</p>
					</div>

					<div>
						<label for="full_name" class="block text-sm font-medium text-gray-700 mb-1.5">
							이름
						</label>
						<input
							id="full_name"
							name="full_name"
							type="text"
							value={form?.full_name || ''}
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="홍길동 (선택사항)"
						/>
					</div>

					<div>
						<label for="email" class="block text-sm font-medium text-gray-700 mb-1.5">
							이메일 <span class="text-red-500">*</span>
						</label>
						<input
							id="email"
							name="email"
							type="email"
							required
							value={form?.email || ''}
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="your@email.com"
						/>
					</div>

					<div>
						<label for="password" class="block text-sm font-medium text-gray-700 mb-1.5">
							비밀번호 <span class="text-red-500">*</span>
						</label>
						<input
							id="password"
							name="password"
							type="password"
							required
							minlength="6"
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="최소 6자 이상"
						/>
					</div>

					<div>
						<label for="bio" class="block text-sm font-medium text-gray-700 mb-1.5">
							자기소개
						</label>
						<textarea
							id="bio"
							name="bio"
							rows="3"
							value={form?.bio || ''}
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm resize-none"
							placeholder="커피에 대한 나의 이야기를 짧게 소개해주세요 (선택사항)"
						></textarea>
					</div>

					<div>
						<label for="location" class="block text-sm font-medium text-gray-700 mb-1.5">
							위치
						</label>
						<input
							id="location"
							name="location"
							type="text"
							value={form?.location || ''}
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="서울, 대한민국 (선택사항)"
						/>
					</div>
				</div>

				<button
					type="submit"
					class="w-full py-3.5 px-4 bg-[#7f6251] hover:bg-[#6d5343] active:bg-[#5d4a3f] text-white font-medium rounded-xl transition-colors text-sm shadow-sm"
				>
					회원가입
				</button>
			</form>
		</div>
	</div>

	<!-- 하단 로그인 링크 -->
	<div class="pb-8 text-center">
		<a href="/login" class="text-sm text-[#7f6251] hover:text-[#5d4a3f] font-medium">
			이미 계정이 있으신가요? <span class="underline">로그인</span>
		</a>
	</div>
</div>
