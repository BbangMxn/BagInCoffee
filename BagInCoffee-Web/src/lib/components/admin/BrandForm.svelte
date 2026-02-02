<script lang="ts">
	import type { Brand, CreateBrandInput, UpdateBrandInput } from '$lib/types/equipment';
	import { uploadBrandLogo, extractPathFromUrl, deleteStorageFile } from '$lib/utils/storage';
	import { page } from '$app/stores';

	interface Props {
		brand?: Brand | null;
		onSave: (data: CreateBrandInput | UpdateBrandInput) => Promise<void>;
		onCancel: () => void;
	}

	let { brand = null, onSave, onCancel }: Props = $props();

	// 폼 데이터
	let formData = $state({
		name: brand?.name || '',
		name_en: brand?.name_en || '',
		description: brand?.description || '',
		logo_url: brand?.logo_url || '',
		website: brand?.website || '',
		country: brand?.country || '',
		founded_year: brand?.founded_year || null
	});

	// 이미지 업로드 상태
	let selectedFile = $state<File | null>(null);
	let previewUrl = $state<string | null>(brand?.logo_url || null);
	let isUploading = $state(false);
	let uploadError = $state<string | null>(null);

	// 폼 제출 상태
	let isSubmitting = $state(false);

	/**
	 * 파일 선택 핸들러
	 */
	function handleFileSelect(event: Event) {
		const target = event.target as HTMLInputElement;
		const file = target.files?.[0];

		if (!file) {
			selectedFile = null;
			previewUrl = brand?.logo_url || null;
			uploadError = null;
			return;
		}

		// 파일 타입 검증
		const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/svg+xml'];
		if (!allowedTypes.includes(file.type)) {
			uploadError = '허용된 이미지 형식: JPG, PNG, WebP, SVG';
			return;
		}

		// 파일 크기 검증 (5MB)
		if (file.size > 5 * 1024 * 1024) {
			uploadError = '파일 크기는 5MB 이하여야 합니다.';
			return;
		}

		selectedFile = file;
		uploadError = null;

		// 미리보기 생성
		const reader = new FileReader();
		reader.onload = (e) => {
			previewUrl = e.target?.result as string;
		};
		reader.readAsDataURL(file);
	}

	/**
	 * 이미지 업로드 (Supabase Storage)
	 */
	async function uploadImage(): Promise<string | null> {
		if (!selectedFile) return formData.logo_url || null;

		isUploading = true;
		uploadError = null;

		try {
			const supabase = $page.data.supabase;
			const result = await uploadBrandLogo(supabase, selectedFile, brand?.id);

			if (!result.success) {
				uploadError = result.error || '업로드 실패';
				return null;
			}

			// 기존 로고가 있고, 새 로고를 업로드한 경우 기존 로고 삭제
			if (brand?.logo_url && result.publicUrl !== brand.logo_url) {
				const oldPath = extractPathFromUrl(brand.logo_url);
				if (oldPath) {
					await deleteStorageFile(supabase, oldPath);
				}
			}

			return result.publicUrl || null;
		} catch (err: any) {
			uploadError = err.message || '업로드 중 오류 발생';
			return null;
		} finally {
			isUploading = false;
		}
	}

	/**
	 * 이미지 제거
	 */
	function removeImage() {
		selectedFile = null;
		previewUrl = null;
		formData.logo_url = '';
		uploadError = null;

		// 파일 input 초기화
		const fileInput = document.getElementById('logo-upload') as HTMLInputElement;
		if (fileInput) {
			fileInput.value = '';
		}
	}

	/**
	 * 폼 제출
	 */
	async function handleSubmit(event: Event) {
		event.preventDefault();

		if (isSubmitting || isUploading) return;

		// 필수 필드 검증
		if (!formData.name.trim()) {
			alert('브랜드명을 입력해주세요.');
			return;
		}

		isSubmitting = true;

		try {
			// 이미지 업로드 (선택된 파일이 있는 경우)
			let logoUrl = formData.logo_url;
			if (selectedFile) {
				const uploadedUrl = await uploadImage();
				if (!uploadedUrl) {
					alert(uploadError || '이미지 업로드에 실패했습니다.');
					isSubmitting = false;
					return;
				}
				logoUrl = uploadedUrl;
			}

			// 저장할 데이터 준비
			const saveData: CreateBrandInput | UpdateBrandInput = {
				name: formData.name.trim(),
				name_en: formData.name_en.trim() || undefined,
				description: formData.description.trim() || undefined,
				logo_url: logoUrl || undefined,
				website: formData.website.trim() || undefined,
				country: formData.country.trim() || undefined,
				founded_year: formData.founded_year || undefined
			};

			await onSave(saveData);
		} catch (err: any) {
			alert(err.message || '저장 중 오류가 발생했습니다.');
		} finally {
			isSubmitting = false;
		}
	}
</script>

<form onsubmit={handleSubmit} class="space-y-6">
	<!-- 브랜드명 (필수) -->
	<div>
		<label for="name" class="block text-sm font-medium text-gray-700 mb-2">
			브랜드명 <span class="text-red-500">*</span>
		</label>
		<input
			type="text"
			id="name"
			bind:value={formData.name}
			required
			placeholder="예: 라마르조코"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
		/>
	</div>

	<!-- 영문명 -->
	<div>
		<label for="name_en" class="block text-sm font-medium text-gray-700 mb-2">
			브랜드 영문명
		</label>
		<input
			type="text"
			id="name_en"
			bind:value={formData.name_en}
			placeholder="예: La Marzocco"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
		/>
	</div>

	<!-- 로고 이미지 업로드 -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">로고 이미지</label>

		<!-- 미리보기 -->
		{#if previewUrl}
			<div class="mb-4 relative inline-block">
				<img
					src={previewUrl}
					alt="로고 미리보기"
					class="w-32 h-32 object-contain border border-gray-300 rounded-lg bg-white p-2"
				/>
				<button
					type="button"
					onclick={removeImage}
					class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600 transition-colors"
					title="이미지 제거"
				>
					<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M6 18L18 6M6 6l12 12"
						/>
					</svg>
				</button>
			</div>
		{/if}

		<!-- 파일 업로드 -->
		<input
			type="file"
			id="logo-upload"
			accept="image/jpeg,image/jpg,image/png,image/webp,image/svg+xml"
			onchange={handleFileSelect}
			class="block w-full text-sm text-gray-500
				file:mr-4 file:py-2 file:px-4
				file:rounded-lg file:border-0
				file:text-sm file:font-semibold
				file:bg-[#7f6251] file:text-white
				hover:file:bg-[#5d4a3f]
				file:cursor-pointer cursor-pointer"
		/>
		<p class="text-xs text-gray-500 mt-2">JPG, PNG, WebP, SVG (최대 5MB)</p>

		{#if uploadError}
			<p class="text-sm text-red-600 mt-2">{uploadError}</p>
		{/if}
	</div>

	<!-- 설명 -->
	<div>
		<label for="description" class="block text-sm font-medium text-gray-700 mb-2">설명</label>
		<textarea
			id="description"
			bind:value={formData.description}
			rows="4"
			placeholder="브랜드에 대한 간단한 설명을 입력하세요"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent resize-none"
		></textarea>
	</div>

	<!-- 웹사이트 -->
	<div>
		<label for="website" class="block text-sm font-medium text-gray-700 mb-2">공식 웹사이트</label>
		<input
			type="url"
			id="website"
			bind:value={formData.website}
			placeholder="https://example.com"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
		/>
	</div>

	<!-- 국가 & 설립 연도 -->
	<div class="grid grid-cols-2 gap-4">
		<div>
			<label for="country" class="block text-sm font-medium text-gray-700 mb-2">본사 국가</label>
			<select
				id="country"
				bind:value={formData.country}
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
			>
				<option value="">선택</option>
				<option value="KR">대한민국</option>
				<option value="IT">이탈리아</option>
				<option value="US">미국</option>
				<option value="DE">독일</option>
				<option value="CH">스위스</option>
				<option value="JP">일본</option>
				<option value="NL">네덜란드</option>
				<option value="UK">영국</option>
				<option value="FR">프랑스</option>
				<option value="AU">호주</option>
				<option value="CA">캐나다</option>
			</select>
		</div>

		<div>
			<label for="founded_year" class="block text-sm font-medium text-gray-700 mb-2">설립 연도</label>
			<input
				type="number"
				id="founded_year"
				bind:value={formData.founded_year}
				min="1800"
				max={new Date().getFullYear()}
				placeholder="예: 1927"
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
			/>
		</div>
	</div>

	<!-- 버튼 -->
	<div class="flex items-center justify-end gap-3 pt-4 border-t border-gray-200">
		<button
			type="button"
			onclick={onCancel}
			disabled={isSubmitting || isUploading}
			class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
		>
			취소
		</button>
		<button
			type="submit"
			disabled={isSubmitting || isUploading}
			class="px-6 py-2 bg-gradient-to-r from-[#7f6251] to-[#5d4a3f] text-white rounded-lg font-semibold hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
		>
			{#if isSubmitting || isUploading}
				<svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
					<circle
						class="opacity-25"
						cx="12"
						cy="12"
						r="10"
						stroke="currentColor"
						stroke-width="4"
					></circle>
					<path
						class="opacity-75"
						fill="currentColor"
						d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
					></path>
				</svg>
				{isUploading ? '업로드 중...' : '저장 중...'}
			{:else}
				{brand ? '수정' : '추가'}
			{/if}
		</button>
	</div>
</form>
