<script lang="ts">
	import "../app.css";
	import type { LayoutData } from "./$types";

	// 레이아웃 컴포넌트들
	import Header from "$lib/components/layout/Header.svelte";
	import Sidebar from "$lib/components/layout/Sidebar.svelte";
	import BottomNav from "$lib/components/layout/BottomNav.svelte";

	let { children, data } = $props<{ children: any; data: LayoutData }>();
</script>

<div class="min-h-screen bg-gray-50">
	<!-- 상단 헤더 -->
	<Header session={data.session} profile={data.profile} />

	<!-- 사이드바 (햄버거 메뉴로 열림) -->
	<Sidebar session={data.session} profile={data.profile} />

	<!-- 메인 컨텐츠 (상단 헤더 + 하단 네비게이션 공간 확보) -->
	<main class="pt-14 pb-16 min-h-screen">
		{@render children?.()}
	</main>

	<!-- 하단 네비게이션 -->
	<BottomNav session={data.session} />
</div>
