<script lang="ts">
	import logo from '$lib/assets/logo-main.png';

	interface Props {
		size?: "sm" | "md" | "lg" | "xl" | "2xl";
		class?: string;
		clickable?: boolean;
	}

	let { size = "md", class: className = "", clickable = false }: Props = $props();

	const sizes = {
		sm: "h-6",
		md: "h-8",
		lg: "h-10",
		xl: "h-14",
		"2xl": "h-20",
	};
</script>

<img
	src={logo}
	alt="BagInCoffee Logo"
	class={`${sizes[size]} object-contain ${clickable ? 'cursor-pointer transition-transform duration-200 hover:scale-110' : ''} ${className}`}
/>
