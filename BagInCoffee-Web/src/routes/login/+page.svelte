<script lang="ts">
	import type { ActionData } from './$types';
	import Logo from '$lib/components/common/Logo.svelte';

	export let form: ActionData;
</script>

<!-- 모바일 중심 로그인 페이지 -->
<div class="min-h-screen bg-gradient-to-b from-[#f8f4f1] to-white flex flex-col">
	<!-- 로고 섹션 -->
	<div class="flex-1 flex flex-col items-center justify-center px-6 pt-12 pb-6">
		<div class="w-full max-w-sm space-y-8">
			<!-- 로고 -->
			<div class="text-center space-y-4">
				<div class="flex justify-center">
					<Logo size="2xl" />
				</div>
				<h1 class="text-2xl font-bold text-[#5d4a3f]">커피 애호가들의 공간</h1>
				<p class="text-sm text-gray-600">BagInCoffee에 오신 것을 환영합니다</p>
			</div>

			<!-- 에러 메시지 -->
			{#if form?.error}
				<div class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl text-sm">
					{form.error}
				</div>
			{/if}

			<!-- 소셜 로그인 버튼들 (우선) -->
			<div class="space-y-3">
				<!-- Google 로그인 -->
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
						<span>Google로 계속하기</span>
					</button>
				</form>

				<!-- Kakao 로그인 -->
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
						<span>카카오로 계속하기</span>
					</button>
				</form>

				<!-- GitHub 로그인 -->
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
						<span>GitHub로 계속하기</span>
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

			<!-- 이메일/비밀번호 로그인 폼 -->
			<form class="space-y-4" method="POST" action="?/login">
				<div class="space-y-3">
					<div>
						<label for="email" class="block text-sm font-medium text-gray-700 mb-1.5">
							이메일
						</label>
						<input
							id="email"
							name="email"
							type="email"
							required
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="your@email.com"
						/>
					</div>
					<div>
						<label for="password" class="block text-sm font-medium text-gray-700 mb-1.5">
							비밀번호
						</label>
						<input
							id="password"
							name="password"
							type="password"
							required
							class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] focus:border-transparent text-sm"
							placeholder="••••••••"
						/>
					</div>
				</div>

				<!-- 로그인/회원가입 버튼 -->
				<div class="space-y-3">
					<button
						type="submit"
						class="w-full py-3.5 px-4 bg-[#7f6251] hover:bg-[#6d5343] active:bg-[#5d4a3f] text-white font-medium rounded-xl transition-colors text-sm shadow-sm"
					>
						로그인
					</button>
					<a
						href="/signup"
						class="block w-full py-3.5 px-4 bg-white border-2 border-[#7f6251] text-[#7f6251] hover:bg-[#f8f4f1] active:bg-[#e5e7eb] font-medium rounded-xl transition-colors text-sm text-center shadow-sm"
					>
						회원가입
					</a>
				</div>
			</form>
		</div>
	</div>
</div>
