<script lang="ts">
	import { onMount } from 'svelte';
	import { equipmentApi } from '$lib/api';
	import type { EquipmentCategory, EquipmentWithCategory } from '$lib/types/equipment';

	let categories: EquipmentCategory[] = [];
	let featuredEquipment: EquipmentWithCategory[] = [];
	let loading = true;
	let error: string | null = null;

	async function loadData() {
		loading = true;
		error = null;

		try {
			// 카테고리 목록 로드
			const categoriesResponse = await equipmentApi.getCategories();
			if (categoriesResponse.success && categoriesResponse.data) {
				categories = categoriesResponse.data;
			}

			// 추천 장비 로드 (최신 8개)
			const equipmentResponse = await equipmentApi.getAll({ page: 1, page_size: 8 });
			if (equipmentResponse.success && equipmentResponse.data) {
				featuredEquipment = equipmentResponse.data;
			}
		} catch (err: any) {
			error = err.message || 'Failed to load data';
		}

		loading = false;
	}

	onMount(() => {
		loadData();
	});
</script>

<div class="equipment-page">
	<header class="hero">
		<h1>☕ 커피 장비</h1>
		<p>완벽한 커피를 위한 최고의 도구들을 찾아보세요</p>
	</header>

	{#if loading}
		<div class="loading">로딩중...</div>
	{:else if error}
		<div class="error">{error}</div>
	{:else}
		<!-- 카테고리 목록 -->
		<section class="categories-section">
			<h2>카테고리</h2>
			<div class="categories-grid">
				{#each categories as category (category.id)}
					<a href="/equipment/category/{category.id}" class="category-card">
						<div class="icon">{category.icon || '📦'}</div>
						<h3>{category.name}</h3>
						{#if category.description}
							<p>{category.description}</p>
						{/if}
					</a>
				{/each}
			</div>
		</section>

		<!-- 전체 장비 보기 버튼 -->
		<section class="all-equipment-section">
			<a href="/equipment/all" class="view-all-btn"> 모든 장비 보기 → </a>
		</section>

		<!-- 추천 장비 -->
		{#if featuredEquipment.length > 0}
			<section class="featured-section">
				<h2>추천 장비</h2>
				<div class="equipment-grid">
					{#each featuredEquipment as item (item.id)}
						<a href="/equipment/{item.id}" class="equipment-card">
							{#if item.image_url}
								<img src={item.image_url} alt={item.model} />
							{:else}
								<div class="no-image">이미지 없음</div>
							{/if}

							<div class="info">
								<span class="brand">{item.brand}</span>
								<h3>{item.model}</h3>

								{#if item.category}
									<span class="category-badge">{item.category.name}</span>
								{/if}

								{#if item.rating}
									<div class="rating">⭐ {item.rating.toFixed(1)} ({item.reviews_count || 0})</div>
								{/if}

								{#if item.price_range}
									<div class="price">{item.price_range}</div>
								{/if}
							</div>
						</a>
					{/each}
				</div>
			</section>
		{/if}
	{/if}
</div>

<style>
	.equipment-page {
		max-width: 1200px;
		margin: 0 auto;
		padding: 20px;
	}

	.hero {
		text-align: center;
		padding: 60px 20px;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border-radius: 12px;
		margin-bottom: 40px;
	}

	.hero h1 {
		font-size: 48px;
		margin-bottom: 16px;
	}

	.hero p {
		font-size: 18px;
		opacity: 0.9;
	}

	.loading,
	.error {
		text-align: center;
		padding: 40px;
	}

	.error {
		color: red;
	}

	/* 카테고리 섹션 */
	.categories-section {
		margin-bottom: 60px;
	}

	.categories-section h2 {
		font-size: 32px;
		margin-bottom: 24px;
	}

	.categories-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
		gap: 20px;
	}

	.category-card {
		border: 2px solid #e9ecef;
		border-radius: 12px;
		padding: 24px;
		text-align: center;
		text-decoration: none;
		color: inherit;
		transition: all 0.3s;
		background: white;
	}

	.category-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
		border-color: #667eea;
	}

	.category-card .icon {
		font-size: 48px;
		margin-bottom: 12px;
	}

	.category-card h3 {
		margin: 0 0 8px 0;
		font-size: 18px;
	}

	.category-card p {
		margin: 0;
		font-size: 14px;
		color: #666;
	}

	/* 전체 보기 버튼 */
	.all-equipment-section {
		text-align: center;
		margin-bottom: 60px;
	}

	.view-all-btn {
		display: inline-block;
		padding: 16px 32px;
		background: #667eea;
		color: white;
		text-decoration: none;
		border-radius: 8px;
		font-weight: 600;
		font-size: 16px;
		transition: background 0.3s;
	}

	.view-all-btn:hover {
		background: #5568d3;
	}

	/* 추천 장비 섹션 */
	.featured-section h2 {
		font-size: 32px;
		margin-bottom: 24px;
	}

	.equipment-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
		gap: 20px;
	}

	.equipment-card {
		border: 1px solid #ddd;
		border-radius: 8px;
		overflow: hidden;
		text-decoration: none;
		color: inherit;
		transition: transform 0.2s;
		background: white;
	}

	.equipment-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
	}

	.equipment-card img,
	.no-image {
		width: 100%;
		height: 200px;
		object-fit: cover;
		background: #f5f5f5;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #999;
	}

	.info {
		padding: 16px;
	}

	.brand {
		font-size: 12px;
		color: #666;
		text-transform: uppercase;
	}

	.info h3 {
		margin: 4px 0 8px 0;
		font-size: 16px;
	}

	.category-badge {
		display: inline-block;
		background: #e9ecef;
		padding: 4px 8px;
		border-radius: 4px;
		font-size: 12px;
		color: #495057;
		margin-bottom: 8px;
	}

	.rating {
		font-size: 14px;
		margin: 8px 0;
	}

	.price {
		font-weight: 600;
		color: #667eea;
	}
</style>
