<script lang="ts">
	import type { PageData } from './$types';

	let { data } = $props<{ data: PageData }>();
	const grinders = $derived(data.grinders || []);
	const error = $derived(data.error);
</script>

<div class="max-w-6xl mx-auto px-4 py-6">
	<!-- Header -->
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-[#5d4a3f] mb-2">그라인더</h1>
		<p class="text-[#7f6251]">완벽한 추출을 위한 그라인더를 찾아보세요</p>
	</div>

	<!-- Equipment Grid -->
	<div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
		{#each grinders as grinder}
			<a
				href="/equipment/{grinder.id}"
				class="bg-white rounded-lg border border-[#e5e7eb] overflow-hidden hover:shadow-lg transition-shadow group"
			>
				<!-- Image -->
				<div class="aspect-[4/3] bg-[#f5f5f0] relative overflow-hidden">
					<div
						class="absolute inset-0 bg-gradient-to-br from-[#d2bab0]/20 to-[#bfa094]/30 flex items-center justify-center"
					>
						<div class="text-[#bfa094]/30 text-6xl font-light">{grinder.brand.slice(0, 1)}</div>
					</div>
					<div
						class="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity"
					></div>
				</div>

				<!-- Content -->
				<div class="p-5">
					<!-- Brand & Rating -->
					<div class="flex items-center justify-between mb-2">
						<span class="text-xs text-[#bfa094] uppercase tracking-wider font-semibold"
							>{grinder.brand}</span
						>
						<div class="flex items-center gap-1">
							<svg class="w-4 h-4 text-[#bfa094]" fill="currentColor" viewBox="0 0 20 20">
								<path
									d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
								/>
							</svg>
							<span class="text-sm text-[#5d4a3f] font-medium">{grinder.rating}</span>
						</div>
					</div>

					<!-- Name -->
					<h3 class="text-lg font-bold text-[#5d4a3f] mb-2 group-hover:text-[#bfa094] transition-colors">
						{grinder.name}
					</h3>

					<!-- Description -->
					<p class="text-sm text-[#7f6251] mb-4 line-clamp-2">{grinder.description}</p>

					<!-- Price & Reviews -->
					<div class="flex items-center justify-between pt-4 border-t border-[#e5e7eb]">
						<div>
							{#if grinder.price}
								<span class="text-xl font-bold text-[#bfa094]"
									>{grinder.price.toLocaleString()}원</span
								>
							{:else if grinder.price_range}
								<span class="text-xl font-bold text-[#bfa094]">{grinder.price_range}</span>
							{:else}
								<span class="text-sm text-[#9ca3af]">가격 문의</span>
							{/if}
						</div>
						<span class="text-xs text-[#9ca3af]">리뷰 {grinder.reviews_count || 0}</span>
					</div>
				</div>
			</a>
		{/each}
	</div>
</div>
