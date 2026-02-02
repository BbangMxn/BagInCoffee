<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import Logo from '$lib/components/common/Logo.svelte';

	let show = $state(false);
	let fadeOut = $state(false);
	let loaded = $state(false);

	onMount(() => {
		// Fade in animation
		setTimeout(() => {
			show = true;
		}, 100);

		// Check if page is loaded
		const checkLoaded = () => {
			// Check if document is fully loaded
			if (document.readyState === 'complete') {
				loaded = true;

				// Start fade out immediately after load
				fadeOut = true;

				// Navigate after fade out animation
				setTimeout(() => {
					goto('/');
				}, 500);
			} else {
				// Check again after a short delay
				setTimeout(checkLoaded, 100);
			}
		};

		// Start checking
		checkLoaded();

		// Fallback: max 5 seconds even if not loaded
		setTimeout(() => {
			if (!loaded) {
				loaded = true;
				fadeOut = true;
				setTimeout(() => {
					goto('/');
				}, 500);
			}
		}, 5000);
	});
</script>

<!-- Splash Screen -->
<div
	class={`fixed inset-0 bg-gradient-to-br from-[#f5f5f0] via-white to-[#f2e8e5] flex items-center justify-center z-50 transition-opacity duration-500 ${
		fadeOut ? 'opacity-0' : 'opacity-100'
	}`}
>
	<div
		class={`text-center transition-all duration-700 ${
			show ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
		}`}
	>
		<!-- Logo -->
		<div class="flex justify-center mb-8">
			<div class={`transition-all duration-700 ${show ? 'scale-100' : 'scale-95'}`}>
				<Logo size="xl" />
			</div>
		</div>

		<!-- Brand Name -->
		<div class="mb-2">
			<h1 class="text-4xl md:text-5xl font-light tracking-[0.3em] text-[#5d4a3f] mb-2">
				BAG IN COFFEE
			</h1>
			<div class="flex items-center justify-center gap-3 mb-6">
				<div class="w-12 h-[1px] bg-[#bfa094]"></div>
				<p class="text-sm tracking-[0.4em] text-[#bfa094] font-light uppercase">Community</p>
				<div class="w-12 h-[1px] bg-[#bfa094]"></div>
			</div>
		</div>

		<!-- Tagline -->
		<p class="text-base text-[#7f6251] font-light italic mb-8">
			Every cup tells a story
		</p>

		<!-- Loading Animation -->
		<div class="flex justify-center gap-2">
			<div
				class="w-2 h-2 bg-[#bfa094] rounded-full animate-bounce"
				style="animation-delay: 0ms"
			></div>
			<div
				class="w-2 h-2 bg-[#bfa094] rounded-full animate-bounce"
				style="animation-delay: 150ms"
			></div>
			<div
				class="w-2 h-2 bg-[#bfa094] rounded-full animate-bounce"
				style="animation-delay: 300ms"
			></div>
		</div>
	</div>
</div>

<style>
	@keyframes bounce {
		0%,
		100% {
			transform: translateY(0);
		}
		50% {
			transform: translateY(-10px);
		}
	}

	.animate-bounce {
		animation: bounce 1s infinite;
	}
</style>
