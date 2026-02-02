<script lang="ts">
	import type { PageData } from './$types';
	import { goto } from '$app/navigation';
	import type { Brand, CreateBrandInput, UpdateBrandInput } from '$lib/types/equipment';
	import BrandForm from '$lib/components/admin/BrandForm.svelte';

	let { data }: { data: PageData } = $props();

	let brands = $state<Brand[]>(data.brands);
	let totalCount = $state(data.totalCount);

	// 필터 상태
	let searchQuery = $state('');
	let selectedCountry = $state<string>('');

	// 편집 모달
	let showEditModal = $state(false);
	let editingBrand = $state<Brand | null>(null);

	// 생성 모달
	let showCreateModal = $state(false);

	// 필터링된 브랜드
	const filteredBrands = $derived(() => {
		let result = brands;

		// 검색어 필터
		if (searchQuery) {
			const query = searchQuery.toLowerCase();
			result = result.filter(
				(brand) =>
					brand.name?.toLowerCase().includes(query) ||
					brand.name_en?.toLowerCase().includes(query) ||
					brand.description?.toLowerCase().includes(query)
			);
		}

		// 국가 필터
		if (selectedCountry) {
			result = result.filter((brand) => brand.country === selectedCountry);
		}

		return result;
	});

	// 국가 목록 (고유값)
	const countries = $derived(() => {
		const uniqueCountries = new Set(
			brands.map((b) => b.country).filter((c): c is string => !!c)
		);
		return Array.from(uniqueCountries).sort();
	});

	function openEditModal(brand: Brand) {
		editingBrand = brand;
		showEditModal = true;
	}

	function closeEditModal() {
		showEditModal = false;
		editingBrand = null;
	}

	function openCreateModal() {
		showCreateModal = true;
	}

	function closeCreateModal() {
		showCreateModal = false;
	}

	async function deleteBrand(id: string, name: string) {
		if (!confirm(`"${name}" 브랜드를 삭제하시겠습니까?`)) return;

		try {
			const response = await fetch(`/api/brands/${id}`, {
				method: 'DELETE'
			});

			if (response.ok) {
				brands = brands.filter((brand) => brand.id !== id);
				totalCount = totalCount - 1;
				alert('삭제되었습니다.');
			} else {
				const error = await response.json();
				throw new Error(error.message || '삭제 실패');
			}
		} catch (err: any) {
			alert(err.message || '오류가 발생했습니다.');
		}
	}

	async function handleSaveEdit(formData: CreateBrandInput | UpdateBrandInput) {
		if (!editingBrand) return;

		try {
			const response = await fetch(`/api/brands/${editingBrand.id}`, {
				method: 'PATCH',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(formData)
			});

			if (response.ok) {
				const result = await response.json();
				// 목록 업데이트
				brands = brands.map((brand) =>
					brand.id === editingBrand!.id ? { ...brand, ...result.data } : brand
				);
				closeEditModal();
				alert('수정되었습니다.');
			} else {
				const error = await response.json();
				throw new Error(error.message || '수정 실패');
			}
		} catch (err: any) {
			alert(err.message || '오류가 발생했습니다.');
		}
	}

	async function handleSaveCreate(formData: CreateBrandInput) {
		try {
			const response = await fetch('/api/brands', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(formData)
			});

			if (response.ok) {
				const result = await response.json();
				// 새 브랜드를 목록에 추가
				brands = [result.data, ...brands];
				totalCount = totalCount + 1;
				closeCreateModal();
				alert('추가되었습니다.');
			} else {
				const error = await response.json();
				throw new Error(error.message || '추가 실패');
			}
		} catch (err: any) {
			alert(err.message || '오류가 발생했습니다.');
		}
	}

	function clearFilters() {
		searchQuery = '';
		selectedCountry = '';
	}
</script>

<div class="min-h-screen bg-gray-50">
	<!-- Header -->
	<div class="bg-white border-b border-gray-200 sticky top-0 z-10">
		<div class="max-w-7xl mx-auto px-4 py-6">
			<div class="flex items-center justify-between">
				<div>
					<h1 class="text-3xl font-bold text-gray-900">브랜드 관리</h1>
					<p class="text-gray-600 mt-1">
						전체 {totalCount}개 브랜드
						{#if filteredBrands().length !== totalCount}
							(필터링: {filteredBrands().length}개)
						{/if}
					</p>
				</div>
				<div class="flex gap-3">
					<button
						onclick={() => goto('/admin')}
						class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
					>
						← 관리자 홈
					</button>
					<button
						onclick={openCreateModal}
						class="px-6 py-2 bg-gradient-to-r from-[#7f6251] to-[#5d4a3f] text-white rounded-lg font-semibold hover:shadow-lg transition-all"
					>
						+ 브랜드 추가
					</button>
				</div>
			</div>
		</div>
	</div>

	<div class="max-w-7xl mx-auto px-4 py-8">
		<!-- Filters -->
		<div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
			<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
				<!-- 검색 -->
				<div class="md:col-span-2">
					<label class="block text-sm font-medium text-gray-700 mb-2">검색</label>
					<input
						type="text"
						bind:value={searchQuery}
						placeholder="브랜드명, 영문명, 설명..."
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
					/>
				</div>

				<!-- 국가 -->
				<div>
					<label class="block text-sm font-medium text-gray-700 mb-2">국가</label>
					<select
						bind:value={selectedCountry}
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
					>
						<option value="">전체</option>
						{#each countries() as country}
							<option value={country}>{country}</option>
						{/each}
					</select>
				</div>
			</div>

			{#if searchQuery || selectedCountry}
				<div class="mt-4">
					<button
						onclick={clearFilters}
						class="text-sm text-[#7f6251] hover:text-[#5d4a3f] font-medium"
					>
						필터 초기화
					</button>
				</div>
			{/if}
		</div>

		<!-- Brands Grid -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
			{#each filteredBrands() as brand}
				<div
					class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow"
				>
					<!-- 로고 -->
					<div class="aspect-video bg-gray-50 flex items-center justify-center p-4">
						{#if brand.logo_url}
							<img
								src={brand.logo_url}
								alt={brand.name}
								class="max-w-full max-h-full object-contain"
								loading="lazy"
								decoding="async"
							/>
						{:else}
							<div class="text-gray-400 text-center">
								<svg
									class="w-16 h-16 mx-auto mb-2"
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
								<span class="text-sm">No Logo</span>
							</div>
						{/if}
					</div>

					<!-- 정보 -->
					<div class="p-4">
						<h3 class="font-bold text-lg text-gray-900 mb-1">{brand.name}</h3>
						{#if brand.name_en}
							<p class="text-sm text-gray-500 mb-2">{brand.name_en}</p>
						{/if}

						{#if brand.description}
							<p class="text-sm text-gray-600 line-clamp-2 mb-3">{brand.description}</p>
						{/if}

						<div class="flex items-center gap-2 text-xs text-gray-500 mb-3">
							{#if brand.country}
								<span class="px-2 py-1 bg-gray-100 rounded">🌍 {brand.country}</span>
							{/if}
							{#if brand.founded_year}
								<span class="px-2 py-1 bg-gray-100 rounded">📅 {brand.founded_year}</span>
							{/if}
						</div>

						{#if brand.website}
							<a
								href={brand.website}
								target="_blank"
								rel="noopener noreferrer"
								class="text-sm text-[#7f6251] hover:text-[#5d4a3f] flex items-center gap-1 mb-3"
							>
								<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
									/>
								</svg>
								웹사이트 방문
							</a>
						{/if}

						<!-- 액션 버튼 -->
						<div class="flex items-center gap-2 pt-3 border-t border-gray-200">
							<button
								onclick={() => openEditModal(brand)}
								class="flex-1 px-3 py-2 text-sm text-green-600 hover:bg-green-50 rounded-lg transition-colors"
							>
								수정
							</button>
							<button
								onclick={() => deleteBrand(brand.id, brand.name)}
								class="flex-1 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors"
							>
								삭제
							</button>
						</div>
					</div>
				</div>
			{:else}
				<div class="col-span-full text-center py-12 text-gray-500">
					{#if searchQuery || selectedCountry}
						검색 결과가 없습니다.
					{:else}
						등록된 브랜드가 없습니다.
					{/if}
				</div>
			{/each}
		</div>
	</div>
</div>

<!-- Edit Modal -->
{#if showEditModal && editingBrand}
	<div
		class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
		onclick={closeEditModal}
	>
		<div
			class="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
			onclick={(e) => e.stopPropagation()}
		>
			<div class="p-6 border-b border-gray-200">
				<h2 class="text-2xl font-bold text-gray-900">브랜드 수정</h2>
				<p class="text-sm text-gray-600 mt-1">{editingBrand.name}</p>
			</div>
			<div class="p-6">
				<BrandForm brand={editingBrand} onSave={handleSaveEdit} onCancel={closeEditModal} />
			</div>
		</div>
	</div>
{/if}

<!-- Create Modal -->
{#if showCreateModal}
	<div
		class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
		onclick={closeCreateModal}
	>
		<div
			class="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
			onclick={(e) => e.stopPropagation()}
		>
			<div class="p-6 border-b border-gray-200">
				<h2 class="text-2xl font-bold text-gray-900">브랜드 추가</h2>
			</div>
			<div class="p-6">
				<BrandForm onSave={handleSaveCreate} onCancel={closeCreateModal} />
			</div>
		</div>
	</div>
{/if}
