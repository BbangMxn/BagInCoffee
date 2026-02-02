<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";

	let content = $state("");
	let selectedImages = $state<File[]>([]);
	let mood = $state("");
	let showAllImages = $state(false);
	let isSubmitting = $state(false);
	let errorMessage = $state("");

	// Check if this is announcement mode
	const isAnnouncementMode = $derived($page.url.searchParams.get("type") === "announcement");

	function handleImageSelect(e: Event) {
		const target = e.target as HTMLInputElement;
		if (target.files) {
			// Add new images to existing ones instead of replacing
			const newImages = Array.from(target.files);

			// 최대 10개 제한
			if (selectedImages.length + newImages.length > 10) {
				errorMessage = "최대 10개의 이미지만 업로드할 수 있습니다.";
				setTimeout(() => errorMessage = "", 3000);
				return;
			}

			selectedImages = [...selectedImages, ...newImages];

			// Reset input so same file can be selected again
			target.value = "";
		}
	}

	function removeImage(index: number) {
		selectedImages = selectedImages.filter((_, i) => i !== index);
	}

	async function handleSubmit() {
		if (!content.trim()) {
			errorMessage = "내용을 입력해주세요.";
			return;
		}

		isSubmitting = true;
		errorMessage = "";

		try {
			let imageUrls: string[] = [];

			// 이미지가 있으면 먼저 업로드
			if (selectedImages.length > 0) {
				const formData = new FormData();
				selectedImages.forEach(image => {
					formData.append('images', image);
				});

				const uploadResponse = await fetch('/api/upload/post-images', {
					method: 'POST',
					body: formData
				});

				if (!uploadResponse.ok) {
					const error = await uploadResponse.json();
					throw new Error(error.message || '이미지 업로드 실패');
				}

				const uploadResult = await uploadResponse.json();
				imageUrls = uploadResult.urls;
			}

			// 게시물 생성 (announcement mode면 자동으로 태그 추가)
			const tags = isAnnouncementMode ? ['developer', 'announcement'] : [];

			const postResponse = await fetch('/api/posts', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					content: content.trim(),
					images: imageUrls,
					tags
				})
			});

			if (!postResponse.ok) {
				const error = await postResponse.json();
				throw new Error(error.message || '게시물 생성 실패');
			}

			// 성공 - announcement면 개발자 페이지로, 아니면 홈으로
			goto(isAnnouncementMode ? "/developer" : "/");
		} catch (error: any) {
			console.error('게시물 생성 에러:', error);
			errorMessage = error.message || '게시물 생성에 실패했습니다.';
		} finally {
			isSubmitting = false;
		}
	}

	// Display count text
	const imageCountText = $derived(
		selectedImages.length > 0 ? `${selectedImages.length}장 선택됨` : "",
	);
</script>

<div class="min-h-screen bg-[#fafafa]">
	<!-- Header -->
	<div class="bg-white border-b border-[#e5e7eb] sticky top-0 z-10">
		<div
			class="max-w-2xl mx-auto px-4 py-3 flex items-center justify-between"
		>
			<button
				onclick={() => goto("/")}
				class="p-2 -ml-2 text-[#7f6251] hover:bg-[#f2e8e5] rounded-full transition-colors"
			>
				<svg
					class="w-5 h-5"
					fill="none"
					stroke="currentColor"
					viewBox="0 0 24 24"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M6 18L18 6M6 6l12 12"
					/>
				</svg>
			</button>
			<h1 class="text-base font-semibold text-[#5d4a3f]">
				{isAnnouncementMode ? '📢 공지사항 작성' : '새 게시글'}
			</h1>
			<button
				onclick={handleSubmit}
				class="px-4 py-1.5 bg-[#bfa094] text-white rounded-full text-sm font-medium hover:bg-[#a18072] transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
				disabled={!content.trim() || isSubmitting}
			>
				{isSubmitting ? '업로드 중...' : '게시'}
			</button>
		</div>
	</div>

	<!-- Content Area -->
	<div class="max-w-2xl mx-auto">
		<!-- Error Message -->
		{#if errorMessage}
			<div class="mx-4 mt-4 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl text-sm">
				{errorMessage}
			</div>
		{/if}

		<!-- Loading Overlay -->
		{#if isSubmitting}
			<div class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
				<div class="bg-white rounded-xl p-6 max-w-sm mx-4">
					<div class="flex flex-col items-center space-y-4">
						<div class="w-12 h-12 border-4 border-[#bfa094] border-t-transparent rounded-full animate-spin"></div>
						<p class="text-[#5d4a3f] font-medium">게시물을 업로드하는 중...</p>
						<p class="text-sm text-gray-600 text-center">
							{selectedImages.length > 0 ? `${selectedImages.length}개의 이미지를 업로드하고 있습니다.` : '잠시만 기다려주세요.'}
						</p>
					</div>
				</div>
			</div>
		{/if}

		<!-- User Info -->
		<div class="bg-white px-4 pt-4 pb-2 flex items-center gap-3">
			<div
				class="w-10 h-10 rounded-full bg-[#f2e8e5] flex items-center justify-center"
			>
				<svg
					class="w-5 h-5 text-[#bfa094]"
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
			<div>
				<p class="text-sm font-semibold text-[#5d4a3f]">사용자</p>
				<p class="text-xs text-[#9ca3af]">
					{isAnnouncementMode ? '개발자 공지' : '공개'}
				</p>
			</div>
		</div>

		<!-- Announcement Notice -->
		{#if isAnnouncementMode}
			<div class="bg-blue-50 border-l-4 border-blue-500 px-4 py-3 mx-4 mt-3">
				<div class="flex items-start gap-2">
					<svg class="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
					<div class="text-sm">
						<p class="font-medium text-blue-800">개발자 공지사항 모드</p>
						<p class="text-blue-700 mt-1">이 게시물은 개발자 페이지에 공지사항으로 표시됩니다.</p>
					</div>
				</div>
			</div>
		{/if}

		<!-- Text Input -->
		<div class="bg-white px-4 pb-3">
			<textarea
				bind:value={content}
				placeholder={isAnnouncementMode ? "업데이트 소식을 작성해주세요..." : "무슨 생각을 하고 계신가요?"}
				class="w-full min-h-[180px] text-[#5d4a3f] placeholder-[#9ca3af] resize-none focus:outline-none text-[15px] leading-relaxed"
			></textarea>
		</div>

		<!-- Image Preview -->
		{#if selectedImages.length > 0}
			<div class="bg-white px-4 pb-4">
				<!-- Image count header -->
				<div class="mb-2 flex items-center justify-between">
					<p class="text-xs text-[#9ca3af]">{imageCountText}</p>
					{#if selectedImages.length > 4 && !showAllImages}
						<button
							onclick={() => (showAllImages = true)}
							class="text-xs text-[#bfa094] hover:text-[#a18072] transition-colors"
						>
							모두 보기
						</button>
					{:else if selectedImages.length > 4 && showAllImages}
						<button
							onclick={() => (showAllImages = false)}
							class="text-xs text-[#bfa094] hover:text-[#a18072] transition-colors"
						>
							접기
						</button>
					{/if}
				</div>
				<div class="rounded-2xl overflow-hidden">
					{#if selectedImages.length === 1}
						<!-- Single Image: Full Width -->
						<div class="relative w-full max-h-[400px] bg-[#f8f8f8]">
							<img
								src={URL.createObjectURL(selectedImages[0])}
								alt="Preview 1"
								class="w-full h-full object-contain"
							/>
							<button
								onclick={() => removeImage(0)}
								class="absolute top-2 right-2 w-7 h-7 bg-black/70 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/90 transition-all shadow-lg"
							>
								<svg
									class="w-4 h-4"
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2.5"
										d="M6 18L18 6M6 6l12 12"
									/>
								</svg>
							</button>
						</div>
					{:else if selectedImages.length === 2}
						<!-- Two Images: Side by Side -->
						<div class="grid grid-cols-2 gap-1">
							{#each selectedImages as image, index}
								<div class="relative aspect-[4/5] bg-[#f8f8f8]">
									<img
										src={URL.createObjectURL(image)}
										alt="Preview {index + 1}"
										class="w-full h-full object-cover"
									/>
									<button
										onclick={() => removeImage(index)}
										class="absolute top-2 right-2 w-7 h-7 bg-black/70 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/90 transition-all shadow-lg"
									>
										<svg
											class="w-4 h-4"
											fill="none"
											stroke="currentColor"
											viewBox="0 0 24 24"
										>
											<path
												stroke-linecap="round"
												stroke-linejoin="round"
												stroke-width="2.5"
												d="M6 18L18 6M6 6l12 12"
											/>
										</svg>
									</button>
								</div>
							{/each}
						</div>
					{:else if selectedImages.length === 3}
						<!-- Three Images: Left 1, Right 2 Stacked -->
						<div class="grid grid-cols-2 gap-1">
							<div
								class="relative row-span-2 aspect-[4/5] bg-[#f8f8f8]"
							>
								<img
									src={URL.createObjectURL(selectedImages[0])}
									alt="Preview 1"
									class="w-full h-full object-cover"
								/>
								<button
									onclick={() => removeImage(0)}
									class="absolute top-2 right-2 w-7 h-7 bg-black/70 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/90 transition-all shadow-lg"
								>
									<svg
										class="w-4 h-4"
										fill="none"
										stroke="currentColor"
										viewBox="0 0 24 24"
									>
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2.5"
											d="M6 18L18 6M6 6l12 12"
										/>
									</svg>
								</button>
							</div>
							{#each [selectedImages[1], selectedImages[2]] as image, i}
								<div class="relative aspect-[4/5] bg-[#f8f8f8]">
									<img
										src={URL.createObjectURL(image)}
										alt="Preview {i + 2}"
										class="w-full h-full object-cover"
									/>
									<button
										onclick={() => removeImage(i + 1)}
										class="absolute top-2 right-2 w-7 h-7 bg-black/70 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/90 transition-all shadow-lg"
									>
										<svg
											class="w-4 h-4"
											fill="none"
											stroke="currentColor"
											viewBox="0 0 24 24"
										>
											<path
												stroke-linecap="round"
												stroke-linejoin="round"
												stroke-width="2.5"
												d="M6 18L18 6M6 6l12 12"
											/>
										</svg>
									</button>
								</div>
							{/each}
						</div>
					{:else}
						<!-- Four or More Images -->
						{#if showAllImages}
							<!-- Show all images in grid -->
							<div class="grid grid-cols-3 gap-1">
								{#each selectedImages as image, index}
									<div
										class="relative aspect-square bg-[#f8f8f8]"
									>
										<img
											src={URL.createObjectURL(image)}
											alt="Preview {index + 1}"
											class="w-full h-full object-cover"
										/>
										<button
											onclick={() => removeImage(index)}
											class="absolute top-1.5 right-1.5 w-6 h-6 bg-black/70 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/90 transition-all shadow-lg"
										>
											<svg
												class="w-3.5 h-3.5"
												fill="none"
												stroke="currentColor"
												viewBox="0 0 24 24"
											>
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2.5"
													d="M6 18L18 6M6 6l12 12"
												/>
											</svg>
										</button>
									</div>
								{/each}
							</div>
						{:else}
							<!-- 2x2 Grid with count badge -->
							<div class="grid grid-cols-2 gap-1">
								{#each selectedImages.slice(0, 4) as image, index}
									<div
										class="relative aspect-square bg-[#f8f8f8]"
									>
										<img
											src={URL.createObjectURL(image)}
											alt="Preview {index + 1}"
											class="w-full h-full object-cover"
										/>
										<!-- Show count badge on 4th image if more than 4 -->
										{#if index === 3 && selectedImages.length > 4}
											<button
												onclick={() =>
													(showAllImages = true)}
												class="absolute inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center text-white text-2xl font-semibold hover:bg-black/70 transition-all"
											>
												+{selectedImages.length - 4}
											</button>
										{/if}
										<button
											onclick={() => removeImage(index)}
											class="absolute top-2 right-2 w-7 h-7 bg-black/70 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/90 transition-all shadow-lg z-10"
										>
											<svg
												class="w-4 h-4"
												fill="none"
												stroke="currentColor"
												viewBox="0 0 24 24"
											>
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2.5"
													d="M6 18L18 6M6 6l12 12"
												/>
											</svg>
										</button>
									</div>
								{/each}
							</div>
						{/if}
					{/if}
				</div>
			</div>
		{/if}

		<!-- Actions Bar -->
		<div class="bg-white border-t border-[#e5e7eb] px-4 py-3">
			<div class="flex items-center gap-1">
				<!-- Photo Upload -->
				<label
					class="flex items-center justify-center w-9 h-9 rounded-full hover:bg-[#f2e8e5] transition-colors cursor-pointer group"
				>
					<input
						type="file"
						multiple
						accept="image/*"
						onchange={handleImageSelect}
						class="hidden"
					/>
					<svg
						class="w-5 h-5 text-[#7f6251] group-hover:text-[#5d4a3f]"
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
				</label>

				<!-- Mood -->
				<button
					class="flex items-center justify-center w-9 h-9 rounded-full hover:bg-[#f2e8e5] transition-colors group"
				>
					<svg
						class="w-5 h-5 text-[#7f6251] group-hover:text-[#5d4a3f]"
						fill="none"
						stroke="currentColor"
						viewBox="0 0 24 24"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
				</button>

				<!-- Location -->
				<button
					class="flex items-center justify-center w-9 h-9 rounded-full hover:bg-[#f2e8e5] transition-colors group"
				>
					<svg
						class="w-5 h-5 text-[#7f6251] group-hover:text-[#5d4a3f]"
						fill="none"
						stroke="currentColor"
						viewBox="0 0 24 24"
					>
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
				</button>
			</div>
		</div>
	</div>
</div>
