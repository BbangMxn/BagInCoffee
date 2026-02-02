<script lang="ts">
	import type { EquipmentWithRelations, Brand, EquipmentCategory } from '$lib/types/equipment';
	import { uploadEquipmentImage, extractPathFromUrl, deleteStorageFile } from '$lib/utils/storage';
	import { page } from '$app/stores';

	interface Props {
		equipment?: EquipmentWithRelations | null;
		brands: Brand[];
		categories: EquipmentCategory[];
		onSave: (data: any) => void;
		onCancel: () => void;
	}

	let { equipment = null, brands, categories, onSave, onCancel }: Props = $props();

	// 폼 데이터
	let formData = $state({
		brand_id: equipment?.brand_id || '',
		category_id: equipment?.category_id || '',
		model: equipment?.model || '',
		description: equipment?.description || '',
		image_url: equipment?.image_url || '',
		price_range: equipment?.price_range || '',
		specs: equipment?.specs ? JSON.stringify(equipment.specs, null, 2) : '{}',
		purchase_links: equipment?.purchase_links
			? JSON.stringify(equipment.purchase_links, null, 2)
			: '{}'
	});

	// 이미지 업로드 상태
	let selectedFile = $state<File | null>(null);
	let previewUrl = $state<string | null>(equipment?.image_url || null);
	let isUploading = $state(false);
	let uploadError = $state<string | null>(null);

	let saving = $state(false);
	let error = $state<string | null>(null);

	/**
	 * 파일 선택 핸들러
	 */
	function handleFileSelect(event: Event) {
		const target = event.target as HTMLInputElement;
		const file = target.files?.[0];

		if (!file) {
			selectedFile = null;
			previewUrl = equipment?.image_url || null;
			uploadError = null;
			return;
		}

		// 파일 타입 검증
		const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
		if (!allowedTypes.includes(file.type)) {
			uploadError = '허용된 이미지 형식: JPG, PNG, WebP';
			return;
		}

		// 파일 크기 검증 (10MB)
		if (file.size > 10 * 1024 * 1024) {
			uploadError = '파일 크기는 10MB 이하여야 합니다.';
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
		if (!selectedFile) return formData.image_url || null;

		isUploading = true;
		uploadError = null;

		try {
			const supabase = $page.data.supabase;
			const result = await uploadEquipmentImage(supabase, selectedFile, equipment?.id);

			if (!result.success) {
				uploadError = result.error || '업로드 실패';
				return null;
			}

			// 기존 이미지가 있고, 새 이미지를 업로드한 경우 기존 이미지 삭제
			if (equipment?.image_url && result.publicUrl !== equipment.image_url) {
				const oldPath = extractPathFromUrl(equipment.image_url);
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
		formData.image_url = '';
		uploadError = null;

		// 파일 input 초기화
		const fileInput = document.getElementById('image-upload') as HTMLInputElement;
		if (fileInput) {
			fileInput.value = '';
		}
	}

	async function handleSubmit() {
		error = null;

		// 유효성 검사
		if (!formData.model.trim()) {
			error = '모델명은 필수입니다.';
			return;
		}

		if (!formData.brand_id) {
			error = '브랜드를 선택해주세요.';
			return;
		}

		saving = true;

		try {
			// 이미지 업로드 (선택된 파일이 있는 경우)
			let imageUrl = formData.image_url;
			if (selectedFile) {
				const uploadedUrl = await uploadImage();
				if (!uploadedUrl) {
					error = uploadError || '이미지 업로드에 실패했습니다.';
					saving = false;
					return;
				}
				imageUrl = uploadedUrl;
			}

			// specs와 purchase_links JSON 파싱
			let specs = null;
			let purchase_links = null;

			try {
				if (formData.specs.trim()) {
					specs = JSON.parse(formData.specs);
				}
			} catch {
				error = 'specs JSON 형식이 올바르지 않습니다.';
				saving = false;
				return;
			}

			try {
				if (formData.purchase_links.trim()) {
					purchase_links = JSON.parse(formData.purchase_links);
				}
			} catch {
				error = 'purchase_links JSON 형식이 올바르지 않습니다.';
				saving = false;
				return;
			}

			const data = {
				...formData,
				image_url: imageUrl || undefined,
				specs,
				purchase_links,
				brand: brands.find((b) => b.id === formData.brand_id)?.name || '' // 레거시 지원
			};

			await onSave(data);
		} catch (err: any) {
			error = err.message || '저장 중 오류가 발생했습니다.';
		} finally {
			saving = false;
		}
	}
</script>

<div class="space-y-6">
	{#if error}
		<div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
			{error}
		</div>
	{/if}

	<!-- 기본 정보 -->
	<div class="grid grid-cols-2 gap-4">
		<div>
			<label class="block text-sm font-medium text-gray-700 mb-2">
				브랜드 <span class="text-red-500">*</span>
			</label>
			<select
				bind:value={formData.brand_id}
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
				required
			>
				<option value="">선택하세요</option>
				{#each brands as brand}
					<option value={brand.id}>{brand.name} {brand.country ? `(${brand.country})` : ''}</option>
				{/each}
			</select>
		</div>

		<div>
			<label class="block text-sm font-medium text-gray-700 mb-2"> 카테고리 </label>
			<select
				bind:value={formData.category_id}
				class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
			>
				<option value="">선택하세요</option>
				{#each categories as category}
					<option value={category.id}>{category.name}</option>
				{/each}
			</select>
		</div>
	</div>

	<!-- 모델명 -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">
			모델명 <span class="text-red-500">*</span>
		</label>
		<input
			type="text"
			bind:value={formData.model}
			placeholder="예: V60-02"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
			required
		/>
	</div>

	<!-- 설명 -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">설명</label>
		<textarea
			bind:value={formData.description}
			rows="3"
			placeholder="제품 설명을 입력하세요"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent resize-none"
		></textarea>
	</div>

	<!-- 이미지 업로드 -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">제품 이미지</label>

		<!-- 미리보기 -->
		{#if previewUrl}
			<div class="mb-4 relative inline-block">
				<img
					src={previewUrl}
					alt="이미지 미리보기"
					class="w-48 h-48 object-cover border border-gray-300 rounded-lg"
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
			id="image-upload"
			accept="image/jpeg,image/jpg,image/png,image/webp"
			onchange={handleFileSelect}
			class="block w-full text-sm text-gray-500
				file:mr-4 file:py-2 file:px-4
				file:rounded-lg file:border-0
				file:text-sm file:font-semibold
				file:bg-[#7f6251] file:text-white
				hover:file:bg-[#5d4a3f]
				file:cursor-pointer cursor-pointer"
		/>
		<p class="text-xs text-gray-500 mt-2">JPG, PNG, WebP (최대 10MB)</p>

		{#if uploadError}
			<p class="text-sm text-red-600 mt-2">{uploadError}</p>
		{/if}

		<!-- 또는 URL 직접 입력 -->
		<div class="mt-3">
			<label class="block text-xs font-medium text-gray-600 mb-1">또는 이미지 URL 직접 입력</label>
			<input
				type="url"
				bind:value={formData.image_url}
				placeholder="https://example.com/image.jpg"
				class="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
			/>
		</div>
	</div>

	<!-- 가격대 -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">가격대</label>
		<input
			type="text"
			bind:value={formData.price_range}
			placeholder="예: 30만원대, 100-200만원"
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
		/>
	</div>

	<!-- Specs (JSON) -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">
			제품 사양 (JSON)
			<span class="text-xs text-gray-500 font-normal ml-2"
				>예: {"{"}"재질": "세라믹", "크기": "02"{"}"}</span
			>
		</label>
		<textarea
			bind:value={formData.specs}
			rows="6"
			placeholder='&#123;"재질": "세라믹", "크기": "02 (1-4인분)"&#125;'
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent font-mono text-sm resize-none"
		></textarea>
	</div>

	<!-- Purchase Links (JSON) -->
	<div>
		<label class="block text-sm font-medium text-gray-700 mb-2">
			구매 링크 (JSON)
			<span class="text-xs text-gray-500 font-normal ml-2"
				>예: {"{"}"naver": "https://...", "coupang": "https://..."{"}"}</span
			>
		</label>
		<textarea
			bind:value={formData.purchase_links}
			rows="6"
			placeholder='&#123;"naver": "https://shopping.naver.com/...", "coupang": "https://www.coupang.com/..."&#125;'
			class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent font-mono text-sm resize-none"
		></textarea>
	</div>

	<!-- 액션 버튼 -->
	<div class="flex justify-end gap-3 pt-4 border-t border-gray-200">
		<button
			onclick={onCancel}
			type="button"
			disabled={saving || isUploading}
			class="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
		>
			취소
		</button>
		<button
			onclick={handleSubmit}
			type="button"
			disabled={saving || isUploading}
			class="px-6 py-2 bg-gradient-to-r from-[#7f6251] to-[#5d4a3f] text-white rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
		>
			{#if saving || isUploading}
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
				저장
			{/if}
		</button>
	</div>
</div>
