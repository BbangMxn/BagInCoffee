<script lang="ts">
	import type { Session } from '@supabase/supabase-js';

	interface Props {
		session?: Session | null;
	}

	let { session = null }: Props = $props();

	interface NavItem {
		label: string;
		href: string;
		active?: boolean;
	}

	const loggedInNavItems: NavItem[] = [
		{ label: '홈', href: '/', active: true },
		{ label: '상품', href: '/products' },
		{ label: '주문', href: '/orders' },
		{ label: '고객', href: '/customers' },
		{ label: '분석', href: '/analytics' },
		{ label: '마케팅', href: '/marketing' },
		{ label: '리포트', href: '/reports' }
	];

	const publicNavItems: NavItem[] = [
		{ label: '홈', href: '/', active: true },
		{ label: '소개', href: '/about' },
		{ label: '서비스', href: '/services' },
		{ label: '문의', href: '/contact' }
	];

	$effect(() => {
		navItems = session ? loggedInNavItems : publicNavItems;
	});

	let navItems = session ? loggedInNavItems : publicNavItems;
</script>

<nav class="bg-white border-b border-gray-200 fixed top-16 left-0 right-0 z-40">
	<div class="px-4">
		<div class="flex space-x-8 h-12 items-center overflow-x-auto">
			{#each navItems as item}
				<a
					href={item.href}
					class={`text-sm font-medium whitespace-nowrap pb-3 ${
						item.active
							? 'text-gray-900 border-b-2 border-blue-600'
							: 'text-gray-600 hover:text-blue-600'
					}`}
				>
					{item.label}
				</a>
			{/each}
		</div>
	</div>
</nav>
