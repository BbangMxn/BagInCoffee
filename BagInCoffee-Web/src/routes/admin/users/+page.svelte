<script lang="ts">
	import { goto } from "$app/navigation";
	import { enhance } from "$app/forms";
	import type { PageData, ActionData } from "./$types";

	let { data, form }: { data: PageData; form: ActionData } = $props();

	let searchQuery = $state(data.search || "");
	let selectedRole = $state(data.roleFilter || "");
	let showRoleModal = $state(false);
	let selectedUser = $state<any>(null);
	let newRole = $state<"user" | "admin" | "moderator">("user");

	function handleSearch() {
		const params = new URLSearchParams();
		if (searchQuery) params.set("search", searchQuery);
		if (selectedRole) params.set("role", selectedRole);
		goto(`/admin/users?${params.toString()}`);
	}

	function handleRoleFilter(role: string) {
		selectedRole = role;
		handleSearch();
	}

	function openRoleModal(user: any) {
		selectedUser = user;
		newRole = user.role;
		showRoleModal = true;
	}

	function closeRoleModal() {
		showRoleModal = false;
		selectedUser = null;
	}

	function getRoleBadgeColor(role: string) {
		switch (role) {
			case "admin":
				return "bg-red-100 text-red-700 border-red-200";
			case "moderator":
				return "bg-blue-100 text-blue-700 border-blue-200";
			default:
				return "bg-gray-100 text-gray-700 border-gray-200";
		}
	}

	function getRoleText(role: string) {
		switch (role) {
			case "admin":
				return "관리자";
			case "moderator":
				return "운영자";
			default:
				return "사용자";
		}
	}

	function formatDate(dateString: string) {
		const date = new Date(dateString);
		return date.toLocaleDateString("ko-KR");
	}
</script>

<div class="min-h-screen bg-[#fafafa]">
	<!-- Header -->
	<div class="bg-white border-b border-[#e5e7eb] sticky top-0 z-10">
		<div class="max-w-7xl mx-auto px-4 py-4">
			<div class="flex items-center justify-between mb-4">
				<div class="flex items-center gap-3">
					<button
						onclick={() => goto("/admin")}
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
								d="M15 19l-7-7 7-7"
							/>
						</svg>
					</button>
					<h1 class="text-xl font-bold text-[#5d4a3f]">
						👥 사용자 관리
					</h1>
				</div>
				<div class="text-sm text-gray-600">
					총 {data.total}명
				</div>
			</div>

			<!-- Search and Filter -->
			<div class="flex flex-col sm:flex-row gap-3">
				<div class="flex-1 relative">
					<input
						type="text"
						bind:value={searchQuery}
						onkeydown={(e) => e.key === "Enter" && handleSearch()}
						placeholder="사용자명 또는 이름으로 검색..."
						class="w-full px-4 py-2.5 pl-10 bg-[#f8f4f1] border border-[#e5e7eb] rounded-xl focus:outline-none focus:ring-2 focus:ring-[#bfa094] text-[#5d4a3f]"
					/>
					<svg
						class="w-5 h-5 text-[#9ca3af] absolute left-3 top-3"
						fill="none"
						stroke="currentColor"
						viewBox="0 0 24 24"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
						/>
					</svg>
				</div>
				<button
					onclick={handleSearch}
					class="px-6 py-2.5 bg-[#bfa094] text-white rounded-xl font-medium hover:bg-[#a18072] transition-colors"
				>
					검색
				</button>
			</div>

			<!-- Role Filters -->
			<div class="flex gap-2 mt-3 overflow-x-auto pb-2">
				<button
					onclick={() => handleRoleFilter("")}
					class={`px-4 py-2 rounded-full text-sm font-medium transition-colors whitespace-nowrap ${
						selectedRole === ""
							? "bg-[#bfa094] text-white"
							: "bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f8f4f1]"
					}`}
				>
					전체
				</button>
				<button
					onclick={() => handleRoleFilter("user")}
					class={`px-4 py-2 rounded-full text-sm font-medium transition-colors whitespace-nowrap ${
						selectedRole === "user"
							? "bg-[#bfa094] text-white"
							: "bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f8f4f1]"
					}`}
				>
					사용자
				</button>
				<button
					onclick={() => handleRoleFilter("moderator")}
					class={`px-4 py-2 rounded-full text-sm font-medium transition-colors whitespace-nowrap ${
						selectedRole === "moderator"
							? "bg-[#bfa094] text-white"
							: "bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f8f4f1]"
					}`}
				>
					운영자
				</button>
				<button
					onclick={() => handleRoleFilter("admin")}
					class={`px-4 py-2 rounded-full text-sm font-medium transition-colors whitespace-nowrap ${
						selectedRole === "admin"
							? "bg-[#bfa094] text-white"
							: "bg-white text-[#7f6251] border border-[#e5e7eb] hover:bg-[#f8f4f1]"
					}`}
				>
					관리자
				</button>
			</div>
		</div>
	</div>

	<!-- Success/Error Messages -->
	{#if form?.success}
		<div
			class="max-w-7xl mx-auto px-4 mt-4 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl"
		>
			{form.message}
		</div>
	{/if}
	{#if form?.error}
		<div
			class="max-w-7xl mx-auto px-4 mt-4 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl"
		>
			{form.error}
		</div>
	{/if}

	<!-- User List -->
	<div class="max-w-7xl mx-auto px-4 py-6">
		{#if data.users.length === 0}
			<div class="text-center py-12">
				<svg
					class="w-16 h-16 mx-auto text-gray-400 mb-4"
					fill="none"
					stroke="currentColor"
					viewBox="0 0 24 24"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
					/>
				</svg>
				<p class="text-gray-600">사용자가 없습니다.</p>
			</div>
		{:else}
			<div class="bg-white rounded-xl border border-[#e5e7eb] overflow-hidden">
				<!-- Desktop Table -->
				<div class="hidden md:block overflow-x-auto">
					<table class="w-full">
						<thead class="bg-[#f8f4f1] border-b border-[#e5e7eb]">
							<tr>
								<th
									class="px-6 py-3 text-left text-xs font-semibold text-[#5d4a3f] uppercase tracking-wider"
								>
									사용자
								</th>
								<th
									class="px-6 py-3 text-left text-xs font-semibold text-[#5d4a3f] uppercase tracking-wider"
								>
									권한
								</th>
								<th
									class="px-6 py-3 text-left text-xs font-semibold text-[#5d4a3f] uppercase tracking-wider"
								>
									게시물
								</th>
								<th
									class="px-6 py-3 text-left text-xs font-semibold text-[#5d4a3f] uppercase tracking-wider"
								>
									가입일
								</th>
								<th
									class="px-6 py-3 text-right text-xs font-semibold text-[#5d4a3f] uppercase tracking-wider"
								>
									작업
								</th>
							</tr>
						</thead>
						<tbody class="divide-y divide-[#e5e7eb]">
							{#each data.users as user}
								<tr class="hover:bg-[#f8f4f1] transition-colors">
									<td class="px-6 py-4">
										<div class="flex items-center gap-3">
											{#if user.avatar_url}
												<img
													src={user.avatar_url}
													alt={user.username || "User"}
													class="w-10 h-10 rounded-full object-cover"
												/>
											{:else}
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
											{/if}
											<div>
												<p
													class="font-medium text-[#5d4a3f]"
												>
													{user.username || user.full_name || "익명"}
												</p>
												{#if user.username && user.full_name}
													<p
														class="text-sm text-gray-500"
													>
														{user.full_name}
													</p>
												{/if}
											</div>
										</div>
									</td>
									<td class="px-6 py-4">
										<span
											class={`px-3 py-1 rounded-full text-xs font-medium border ${getRoleBadgeColor(user.role)}`}
										>
											{getRoleText(user.role)}
										</span>
									</td>
									<td class="px-6 py-4 text-sm text-gray-600">
										{user.post_count}개
									</td>
									<td class="px-6 py-4 text-sm text-gray-600">
										{formatDate(user.created_at)}
									</td>
									<td class="px-6 py-4 text-right">
										<div class="flex items-center justify-end gap-2">
											<button
												onclick={() => openRoleModal(user)}
												class="px-3 py-1.5 text-sm text-[#7f6251] hover:bg-[#f2e8e5] rounded-lg transition-colors"
											>
												권한 변경
											</button>
											<a
												href={`/profile/${user.id}`}
												class="px-3 py-1.5 text-sm text-[#7f6251] hover:bg-[#f2e8e5] rounded-lg transition-colors"
											>
												프로필
											</a>
										</div>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>

				<!-- Mobile Cards -->
				<div class="md:hidden divide-y divide-[#e5e7eb]">
					{#each data.users as user}
						<div class="p-4">
							<div class="flex items-start gap-3 mb-3">
								{#if user.avatar_url}
									<img
										src={user.avatar_url}
										alt={user.username || "User"}
										class="w-12 h-12 rounded-full object-cover flex-shrink-0"
									/>
								{:else}
									<div
										class="w-12 h-12 rounded-full bg-[#f2e8e5] flex items-center justify-center flex-shrink-0"
									>
										<svg
											class="w-6 h-6 text-[#bfa094]"
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
								{/if}
								<div class="flex-1 min-w-0">
									<p class="font-medium text-[#5d4a3f]">
										{user.username || user.full_name || "익명"}
									</p>
									{#if user.username && user.full_name}
										<p class="text-sm text-gray-500">
											{user.full_name}
										</p>
									{/if}
									<div class="flex items-center gap-2 mt-1">
										<span
											class={`px-2 py-0.5 rounded-full text-xs font-medium border ${getRoleBadgeColor(user.role)}`}
										>
											{getRoleText(user.role)}
										</span>
										<span class="text-xs text-gray-500">
											게시물 {user.post_count}개
										</span>
									</div>
								</div>
							</div>
							<div
								class="flex items-center justify-between text-sm"
							>
								<span class="text-gray-500">
									가입일: {formatDate(user.created_at)}
								</span>
								<div class="flex gap-2">
									<button
										onclick={() => openRoleModal(user)}
										class="px-3 py-1.5 text-sm text-[#7f6251] hover:bg-[#f2e8e5] rounded-lg transition-colors"
									>
										권한 변경
									</button>
									<a
										href={`/profile/${user.id}`}
										class="px-3 py-1.5 text-sm text-[#7f6251] hover:bg-[#f2e8e5] rounded-lg transition-colors"
									>
										프로필
									</a>
								</div>
							</div>
						</div>
					{/each}
				</div>
			</div>

			<!-- Pagination -->
			{#if data.totalPages > 1}
				<div class="flex justify-center gap-2 mt-6">
					{#if data.page > 1}
						<a
							href={`/admin/users?page=${data.page - 1}${data.search ? `&search=${data.search}` : ""}${data.roleFilter ? `&role=${data.roleFilter}` : ""}`}
							class="px-4 py-2 bg-white border border-[#e5e7eb] rounded-lg text-[#7f6251] hover:bg-[#f8f4f1] transition-colors"
						>
							이전
						</a>
					{/if}
					<div
						class="px-4 py-2 bg-[#bfa094] text-white rounded-lg"
					>
						{data.page} / {data.totalPages}
					</div>
					{#if data.page < data.totalPages}
						<a
							href={`/admin/users?page=${data.page + 1}${data.search ? `&search=${data.search}` : ""}${data.roleFilter ? `&role=${data.roleFilter}` : ""}`}
							class="px-4 py-2 bg-white border border-[#e5e7eb] rounded-lg text-[#7f6251] hover:bg-[#f8f4f1] transition-colors"
						>
							다음
						</a>
					{/if}
				</div>
			{/if}
		{/if}
	</div>
</div>

<!-- Role Change Modal -->
{#if showRoleModal && selectedUser}
	<div
		class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
		onclick={closeRoleModal}
	>
		<div
			class="bg-white rounded-2xl p-6 max-w-md w-full"
			onclick={(e) => e.stopPropagation()}
		>
			<h2 class="text-xl font-bold text-[#5d4a3f] mb-4">
				권한 변경
			</h2>
			<div class="mb-4">
				<p class="text-sm text-gray-600 mb-2">
					<span class="font-medium"
						>{selectedUser.username || selectedUser.full_name || "익명"}</span
					>님의 권한을 변경합니다.
				</p>
			</div>

			<form method="POST" action="?/updateRole" use:enhance>
				<input type="hidden" name="userId" value={selectedUser.id} />
				<div class="space-y-2 mb-6">
					<label class="flex items-center gap-3 p-3 border border-[#e5e7eb] rounded-xl cursor-pointer hover:bg-[#f8f4f1] transition-colors">
						<input
							type="radio"
							name="role"
							value="user"
							bind:group={newRole}
							class="w-4 h-4 text-[#bfa094]"
						/>
						<div>
							<p class="font-medium text-[#5d4a3f]">사용자</p>
							<p class="text-xs text-gray-500">
								일반 사용자 권한
							</p>
						</div>
					</label>
					<label class="flex items-center gap-3 p-3 border border-[#e5e7eb] rounded-xl cursor-pointer hover:bg-[#f8f4f1] transition-colors">
						<input
							type="radio"
							name="role"
							value="moderator"
							bind:group={newRole}
							class="w-4 h-4 text-[#bfa094]"
						/>
						<div>
							<p class="font-medium text-[#5d4a3f]">운영자</p>
							<p class="text-xs text-gray-500">
								게시물 관리 권한
							</p>
						</div>
					</label>
					<label class="flex items-center gap-3 p-3 border border-[#e5e7eb] rounded-xl cursor-pointer hover:bg-[#f8f4f1] transition-colors">
						<input
							type="radio"
							name="role"
							value="admin"
							bind:group={newRole}
							class="w-4 h-4 text-[#bfa094]"
						/>
						<div>
							<p class="font-medium text-[#5d4a3f]">관리자</p>
							<p class="text-xs text-gray-500">
								전체 시스템 관리 권한
							</p>
						</div>
					</label>
				</div>

				<div class="flex gap-3">
					<button
						type="button"
						onclick={closeRoleModal}
						class="flex-1 px-4 py-2.5 bg-white border border-[#e5e7eb] text-[#7f6251] rounded-xl font-medium hover:bg-[#f8f4f1] transition-colors"
					>
						취소
					</button>
					<button
						type="submit"
						class="flex-1 px-4 py-2.5 bg-[#bfa094] text-white rounded-xl font-medium hover:bg-[#a18072] transition-colors"
					>
						변경하기
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}
