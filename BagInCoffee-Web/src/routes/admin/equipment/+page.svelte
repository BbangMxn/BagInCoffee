<script lang="ts">
	import type { PageData } from './$types';
	import { goto } from '$app/navigation';
	import type { EquipmentWithRelations, Brand, EquipmentCategory } from '$lib/types/equipment';
	import EquipmentForm from '$lib/components/admin/EquipmentForm.svelte';

	let { data }: { data: PageData } = $props();

	let equipment = $state<EquipmentWithRelations[]>(data.equipment);
	let categories = $state<EquipmentCategory[]>(data.categories);
	let brands = $state<Brand[]>(data.brands);

	// 필터 상태
	let searchQuery = $state('');
	let selectedCategoryId = $state<string>('');
	let selectedBrandId = $state<string>('');

	// 편집 모달
	let showEditModal = $state(false);
	let editingEquipment = $state<EquipmentWithRelations | null>(null);

	// 생성 모달
	let showCreateModal = $state(false);

	// 필터링된 장비
	const filteredEquipment = $derived(() => {
		let result = equipment;

		// 검색어 필터
		if (searchQuery) {
			const query = searchQuery.toLowerCase();
			result = result.filter(
				(item) =>
					item.model?.toLowerCase().includes(query) ||
					item.brand?.toLowerCase().includes(query) ||
					item.description?.toLowerCase().includes(query)
			);
		}

		// 카테고리 필터
		if (selectedCategoryId) {
			result = result.filter((item) => item.category_id === selectedCategoryId);
		}

		// 브랜드 필터
		if (selectedBrandId) {
			result = result.filter((item) => item.brand_id === selectedBrandId);
		}

		return result;
	});

	function openEditModal(item: EquipmentWithRelations) {
		editingEquipment = item;
		showEditModal = true;
	}

	function closeEditModal() {
		showEditModal = false;
		editingEquipment = null;
	}

	function openCreateModal() {
		showCreateModal = true;
	}

	function closeCreateModal() {
		showCreateModal = false;
	}

	async function deleteEquipment(id: string, model: string) {
		if (!confirm(`"${model}" 장비를 삭제하시겠습니까?`)) return;

		try {
			const response = await fetch(`/api/equipment/${id}`, {
				method: 'DELETE'
			});

			if (response.ok) {
				equipment = equipment.filter((item) => item.id !== id);
				totalCount = totalCount - 1;
				alert('삭제되었습니다.');
			} else{
				alert('삭제 실패');
			}
		} catch (err) {
			alert('오류가 발생했습니다.');
		}
	}

	async function handleSaveEdit(formData: any) {
		if (!editingEquipment) return;

		try {
			const response = await fetch(`/api/equipment/${editingEquipment.id}`, {
				method: 'PATCH',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(formData)
			});

			if (response.ok) {
				const result = await response.json();
				// 목록 업데이트 (상태 관리로 처리)
				equipment = equipment.map((item) =>
					item.id === editingEquipment!.id ? { ...item, ...result.data } : item
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

	async function handleSaveCreate(formData: any) {
		try {
			const response = await fetch('/api/equipment', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(formData)
			});

			if (response.ok) {
				const result = await response.json();
				// 새 아이템을 목록에 추가 (상태 관리로 처리)
				equipment = [result.data, ...equipment];
				totalCount = totalCount + 1;
				closeCreateModal();
				alert('추가되었습니다.');
			} else{
				const error = await response.json();
				throw new Error(error.message || '추가 실패');
			}
		} catch (err: any) {
			alert(err.message || '오류가 발생했습니다.');
		}
	}

	function clearFilters() {
		searchQuery = '';
		selectedCategoryId = '';
		selectedBrandId = '';
	}
</script>

<div class="min-h-screen bg-gray-50">
	<!-- Header -->
	<div class="bg-white border-b border-gray-200 sticky top-0 z-10">
		<div class="max-w-7xl mx-auto px-4 py-6">
			<div class="flex items-center justify-between">
				<div>
					<h1 class="text-3xl font-bold text-gray-900">장비 관리</h1>
					<p class="text-gray-600 mt-1">
						전체 {data.totalCount}개 장비
						{#if filteredEquipment().length !== data.totalCount}
							(필터링: {filteredEquipment().length}개)
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
						+ 장비 추가
					</button>
				</div>
			</div>
		</div>
	</div>

	<div class="max-w-7xl mx-auto px-4 py-8">
		<!-- Filters -->
		<div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
			<div class="grid grid-cols-1 md:grid-cols-4 gap-4">
				<!-- 검색 -->
				<div class="md:col-span-2">
					<label class="block text-sm font-medium text-gray-700 mb-2">검색</label>
					<input
						type="text"
						bind:value={searchQuery}
						placeholder="모델명, 브랜드, 설명..."
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
					/>
				</div>

				<!-- 카테고리 -->
				<div>
					<label class="block text-sm font-medium text-gray-700 mb-2">카테고리</label>
					<select
						bind:value={selectedCategoryId}
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
					>
						<option value="">전체</option>
						{#each categories as category}
							<option value={category.id}>{category.name}</option>
						{/each}
					</select>
				</div>

				<!-- 브랜드 -->
				<div>
					<label class="block text-sm font-medium text-gray-700 mb-2">브랜드</label>
					<select
						bind:value={selectedBrandId}
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7f6251] focus:border-transparent"
					>
						<option value="">전체</option>
						{#each brands as brand}
							<option value={brand.id}>{brand.name}</option>
						{/each}
					</select>
				</div>
			</div>

			{#if searchQuery || selectedCategoryId || selectedBrandId}
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

		<!-- Equipment Table -->
		<div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
			<div class="overflow-x-auto">
				<table class="w-full">
					<thead class="bg-gray-50 border-b border-gray-200">
						<tr>
							<th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
								이미지
							</th>
							<th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
								모델명
							</th>
							<th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
								브랜드
							</th>
							<th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
								카테고리
							</th>
							<th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
								가격대
							</th>
							<th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
								평점
							</th>
							<th class="px-6 py-4 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
								액션
							</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-200">
						{#each filteredEquipment() as item}
							<tr class="hover:bg-gray-50 transition-colors">
								<td class="px-6 py-4">
									{#if item.image_url}
										<img
											src={item.image_url}
											alt={item.model}
											class="w-16 h-16 object-cover rounded-lg"
											loading="lazy"
											decoding="async"
										/>
									{:else}
										<div class="w-16 h-16 bg-gray-200 rounded-lg flex items-center justify-center">
											<span class="text-gray-400 text-xs">No Image</span>
										</div>
									{/if}
								</td>
								<td class="px-6 py-4">
									<div class="font-semibold text-gray-900">{item.model}</div>
									{#if item.description}
										<div class="text-sm text-gray-500 line-clamp-1">{item.description}</div>
									{/if}
								</td>
								<td class="px-6 py-4">
									{#if item.brand_info}
										<div class="flex items-center gap-2">
											{#if item.brand_info.logo_url}
												<img
													src={item.brand_info.logo_url}
													alt={item.brand_info.name}
													class="w-6 h-6 object-contain"
												/>
											{/if}
											<span class="text-sm font-medium text-gray-900">{item.brand_info.name}</span>
										</div>
									{:else}
										<span class="text-sm text-gray-500">{item.brand || '-'}</span>
									{/if}
								</td>
								<td class="px-6 py-4">
									{#if item.equipment_category}
										<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
											{item.equipment_category.name}
										</span>
									{:else}
										<span class="text-sm text-gray-400">-</span>
									{/if}
								</td>
								<td class="px-6 py-4">
									<span class="text-sm text-gray-900">{item.price_range || '-'}</span>
								</td>
								<td class="px-6 py-4">
									{#if item.rating}
										<div class="flex items-center gap-1">
											<span class="text-yellow-400">⭐</span>
											<span class="text-sm font-medium">{item.rating.toFixed(1)}</span>
											<span class="text-xs text-gray-500">({item.reviews_count || 0})</span>
										</div>
									{:else}
										<span class="text-sm text-gray-400">-</span>
									{/if}
								</td>
								<td class="px-6 py-4 text-right">
									<div class="flex items-center justify-end gap-2">
										<a
											href="/equipment/{item.id}"
											target="_blank"
											class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
											title="보기"
										>
											<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
											</svg>
										</a>
										<button
											onclick={() => openEditModal(item)}
											class="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
											title="수정"
										>
											<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
											</svg>
										</button>
										<button
											onclick={() => deleteEquipment(item.id, item.model)}
											class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
											title="삭제"
										>
											<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
											</svg>
										</button>
									</div>
								</td>
							</tr>
						{:else}
							<tr>
								<td colspan="7" class="px-6 py-12 text-center text-gray-500">
									{#if searchQuery || selectedCategoryId || selectedBrandId}
										검색 결과가 없습니다.
									{:else}
										등록된 장비가 없습니다.
									{/if}
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	</div>
</div>

<!-- Edit Modal -->
{#if showEditModal && editingEquipment}
	<div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onclick={closeEditModal}>
		<div class="bg-white rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onclick={(e) => e.stopPropagation()}>
			<div class="p-6 border-b border-gray-200">
				<h2 class="text-2xl font-bold text-gray-900">장비 수정</h2>
				<p class="text-sm text-gray-600 mt-1">{editingEquipment.model}</p>
			</div>
			<div class="p-6">
				<EquipmentForm
					equipment={editingEquipment}
					{brands}
					{categories}
					onSave={handleSaveEdit}
					onCancel={closeEditModal}
				/>
			</div>
		</div>
	</div>
{/if}

<!-- Create Modal -->
{#if showCreateModal}
	<div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onclick={closeCreateModal}>
		<div class="bg-white rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onclick={(e) => e.stopPropagation()}>
			<div class="p-6 border-b border-gray-200">
				<h2 class="text-2xl font-bold text-gray-900">장비 추가</h2>
			</div>
			<div class="p-6">
				<EquipmentForm
					{brands}
					{categories}
					onSave={handleSaveCreate}
					onCancel={closeCreateModal}
				/>
			</div>
		</div>
	</div>
{/if}
