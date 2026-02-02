<script lang="ts">
	import { goto } from '$app/navigation';
	import { guideApi } from '$lib/api';
	import type { GuideCategory } from '$lib/types/content';

	let title = '';
	let content = '';
	let category: GuideCategory = 'brewing';
	let difficulty: 'beginner' | 'intermediate' | 'advanced' | 'master' = 'beginner';
	let estimated_time = 10;
	let thumbnail_url = '';

	let saving = false;
	let error: string | null = null;
	let showPreview = false;

	const categories: { value: GuideCategory; label: string; icon: string }[] = [
		{ value: 'brewing', label: '추출 방법', icon: '☕' },
		{ value: 'beans', label: '원두 가이드', icon: '🫘' },
		{ value: 'equipment', label: '장비 사용법', icon: '⚙️' },
		{ value: 'latte-art', label: '라떼 아트', icon: '🎨' },
		{ value: 'roasting', label: '로스팅', icon: '🔥' },
		{ value: 'other', label: '기타', icon: '📚' }
	];

	const difficulties = [
		{ value: 'beginner', label: '초급', color: 'bg-green-100 text-green-800' },
		{ value: 'intermediate', label: '중급', color: 'bg-blue-100 text-blue-800' },
		{ value: 'advanced', label: '고급', color: 'bg-orange-100 text-orange-800' },
		{ value: 'master', label: '전문가', color: 'bg-red-100 text-red-800' }
	];

	async function handleSubmit(event: Event) {
		event.preventDefault();
		// 유효성 검사
		if (!title.trim()) {
			error = '제목을 입력해주세요';
			return;
		}

		if (!content.trim()) {
			error = '내용을 입력해주세요';
			return;
		}

		if (estimated_time < 1) {
			error = '예상 소요 시간은 최소 1분 이상이어야 합니다';
			return;
		}

		saving = true;
		error = null;

		const response = await guideApi.create({
			title,
			content,
			category,
			difficulty,
			estimated_time,
			thumbnail_url: thumbnail_url || undefined
		});

		saving = false;

		if (response.success && response.data) {
			// 성공 시 가이드 상세 페이지로 이동
			goto(`/guide/${response.data.id}`);
		} else {
			error = response.error?.message || '가이드 저장에 실패했습니다';
		}
	}

	// 마크다운 미리보기를 위한 간단한 변환 (실제로는 marked 라이브러리 사용 권장)
	function renderMarkdown(md: string): string {
		return md
			.replace(/^### (.*$)/gim, '<h3 class="text-lg font-bold mt-4 mb-2">$1</h3>')
			.replace(/^## (.*$)/gim, '<h2 class="text-xl font-bold mt-6 mb-3">$1</h2>')
			.replace(/^# (.*$)/gim, '<h1 class="text-2xl font-bold mt-8 mb-4">$1</h1>')
			.replace(/\*\*(.*)\*\*/gim, '<strong>$1</strong>')
			.replace(/\*(.*)\*/gim, '<em>$1</em>')
			.replace(/\n/gim, '<br>');
	}
</script>

<div class="min-h-screen bg-gray-50">
	<!-- 헤더 -->
	<div class="bg-white border-b border-gray-200">
		<div class="max-w-5xl mx-auto px-4 py-6">
			<div class="flex items-center justify-between">
				<div>
					<h1 class="text-2xl font-bold text-[#5d4a3f]">커피 가이드 작성</h1>
					<p class="text-sm text-gray-600 mt-1">마크다운으로 커피 가이드를 작성하세요</p>
				</div>
				<a
					href="/admin"
					class="px-4 py-2 text-sm font-medium text-[#7f6251] hover:text-[#5d4a3f] transition-colors"
				>
					← 관리자 대시보드
				</a>
			</div>
		</div>
	</div>

	<div class="max-w-5xl mx-auto px-4 py-6">
		{#if error}
			<div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
				<p class="text-sm text-red-800">{error}</p>
			</div>
		{/if}

		<form onsubmit={handleSubmit} class="space-y-6">
			<!-- 기본 정보 -->
			<div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
				<h2 class="text-lg font-bold text-[#5d4a3f] mb-4">기본 정보</h2>

				<!-- 제목 -->
				<div class="mb-4">
					<label for="title" class="block text-sm font-medium text-gray-700 mb-2">
						제목 <span class="text-red-500">*</span>
					</label>
					<input
						type="text"
						id="title"
						bind:value={title}
						placeholder="예: 핸드드립 커피 추출 완벽 가이드"
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#bfa094] focus:border-transparent"
						required
					/>
				</div>

				<!-- 카테고리 & 난이도 -->
				<div class="grid grid-cols-2 gap-4 mb-4">
					<div>
						<label for="category" class="block text-sm font-medium text-gray-700 mb-2">
							카테고리 <span class="text-red-500">*</span>
						</label>
						<select
							id="category"
							bind:value={category}
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#bfa094] focus:border-transparent"
						>
							{#each categories as cat}
								<option value={cat.value}>
									{cat.icon} {cat.label}
								</option>
							{/each}
						</select>
					</div>

					<div>
						<label for="difficulty" class="block text-sm font-medium text-gray-700 mb-2">
							난이도 <span class="text-red-500">*</span>
						</label>
						<select
							id="difficulty"
							bind:value={difficulty}
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#bfa094] focus:border-transparent"
						>
							{#each difficulties as diff}
								<option value={diff.value}>{diff.label}</option>
							{/each}
						</select>
					</div>
				</div>

				<!-- 예상 소요 시간 & 썸네일 -->
				<div class="grid grid-cols-2 gap-4">
					<div>
						<label for="time" class="block text-sm font-medium text-gray-700 mb-2">
							예상 소요 시간 (분) <span class="text-red-500">*</span>
						</label>
						<input
							type="number"
							id="time"
							bind:value={estimated_time}
							min="1"
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#bfa094] focus:border-transparent"
							required
						/>
					</div>

					<div>
						<label for="thumbnail" class="block text-sm font-medium text-gray-700 mb-2">
							썸네일 URL (선택)
						</label>
						<input
							type="url"
							id="thumbnail"
							bind:value={thumbnail_url}
							placeholder="https://example.com/image.jpg"
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#bfa094] focus:border-transparent"
						/>
					</div>
				</div>
			</div>

			<!-- 마크다운 에디터 -->
			<div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
				<div class="border-b border-gray-200 bg-gray-50 px-6 py-3">
					<div class="flex items-center justify-between">
						<h2 class="text-lg font-bold text-[#5d4a3f]">내용</h2>
						<button
							type="button"
							onclick={() => (showPreview = !showPreview)}
							class="px-3 py-1 text-sm font-medium text-[#7f6251] hover:text-[#5d4a3f] border border-gray-300 rounded-lg hover:bg-white transition-colors"
						>
							{showPreview ? '편집 모드' : '미리보기'}
						</button>
					</div>
				</div>

				{#if !showPreview}
					<!-- 마크다운 에디터 -->
					<div class="p-6">
						<textarea
							bind:value={content}
							placeholder="마크다운으로 작성하세요...

# 제목
## 소제목
### 작은 제목

**굵게** *기울임*

- 목록 1
- 목록 2

1. 순서 목록 1
2. 순서 목록 2"
							class="w-full h-96 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#bfa094] focus:border-transparent font-mono text-sm resize-none"
							required
						></textarea>

						<!-- 마크다운 도움말 -->
						<div class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
							<p class="text-sm font-medium text-blue-900 mb-2">💡 마크다운 사용법</p>
							<div class="grid grid-cols-2 gap-2 text-xs text-blue-800">
								<div><code class="bg-blue-100 px-1 rounded"># 제목</code> - 큰 제목</div>
								<div><code class="bg-blue-100 px-1 rounded">## 소제목</code> - 중간 제목</div>
								<div><code class="bg-blue-100 px-1 rounded">**굵게**</code> - 굵은 글씨</div>
								<div><code class="bg-blue-100 px-1 rounded">*기울임*</code> - 기울임 글씨</div>
								<div><code class="bg-blue-100 px-1 rounded">- 항목</code> - 목록</div>
								<div><code class="bg-blue-100 px-1 rounded">1. 항목</code> - 순서 목록</div>
							</div>
						</div>
					</div>
				{:else}
					<!-- 미리보기 -->
					<div class="p-6 prose max-w-none">
						<div class="bg-gray-50 p-6 rounded-lg">
							{@html renderMarkdown(content || '*내용을 입력하세요...*')}
						</div>
					</div>
				{/if}
			</div>

			<!-- 저장 버튼 -->
			<div class="flex justify-end gap-3">
				<a
					href="/admin"
					class="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
				>
					취소
				</a>
				<button
					type="submit"
					disabled={saving}
					class="px-6 py-3 bg-[#bfa094] text-white rounded-lg hover:bg-[#a88f84] disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
				>
					{saving ? '저장 중...' : '가이드 발행'}
				</button>
			</div>
		</form>
	</div>
</div>
