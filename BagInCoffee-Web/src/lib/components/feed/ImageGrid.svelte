<script lang="ts">
	interface Props {
		images: string[];
		lazy?: boolean;
	}

	let { images, lazy = true }: Props = $props();
</script>

{#if images.length > 0}
	<div class="mt-3 border border-[#e5e7eb] rounded-xl overflow-hidden">
		{#if images.length === 1}
			<!-- Single Image: Full Width -->
			<div class="relative w-full max-h-[500px] bg-[#f5f5f0]">
				<img
					src={images[0]}
					alt="게시물 이미지"
					class="w-full h-full object-contain"
					loading={lazy ? 'lazy' : 'eager'}
					decoding="async"
				/>
			</div>
		{:else if images.length === 2}
			<!-- Two Images: Side by Side -->
			<div class="grid grid-cols-2 gap-[2px] bg-[#e5e7eb]">
				{#each images as image, index}
					<div class="relative aspect-[4/5] bg-[#f5f5f0]">
						<img
							src={image}
							alt="게시물 이미지 {index + 1}"
							class="w-full h-full object-cover"
							loading={lazy ? 'lazy' : 'eager'}
							decoding="async"
						/>
					</div>
				{/each}
			</div>
		{:else if images.length === 3}
			<!-- Three Images: Left 1, Right 2 Stacked -->
			<div class="grid grid-cols-2 gap-[2px] bg-[#e5e7eb]">
				<div class="relative row-span-2 aspect-[4/5] bg-[#f5f5f0]">
					<img
						src={images[0]}
						alt="게시물 이미지 1"
						class="w-full h-full object-cover"
						loading={lazy ? 'lazy' : 'eager'}
						decoding="async"
					/>
				</div>
				{#each [images[1], images[2]] as image, i}
					<div class="relative aspect-[4/5] bg-[#f5f5f0]">
						<img
							src={image}
							alt="게시물 이미지 {i + 2}"
							class="w-full h-full object-cover"
							loading={lazy ? 'lazy' : 'eager'}
							decoding="async"
						/>
					</div>
				{/each}
			</div>
		{:else}
			<!-- Four or More Images: 2x2 Grid -->
			<div class="grid grid-cols-2 gap-[2px] bg-[#e5e7eb]">
				{#each images.slice(0, 4) as image, index}
					<div class="relative aspect-square bg-[#f5f5f0]">
						<img
							src={image}
							alt="게시물 이미지 {index + 1}"
							class="w-full h-full object-cover"
							loading={lazy ? 'lazy' : 'eager'}
							decoding="async"
						/>
						<!-- Show count badge on 4th image if more than 4 -->
						{#if index === 3 && images.length > 4}
							<div
								class="absolute inset-0 bg-black/50 flex items-center justify-center text-white text-3xl font-bold"
							>
								+{images.length - 4}
							</div>
						{/if}
					</div>
				{/each}
			</div>
		{/if}
	</div>
{/if}
