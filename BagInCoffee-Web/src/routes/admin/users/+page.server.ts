import { redirect, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { UserRepository } from '$lib/server/database/Repository/user.repository';

export const load: PageServerLoad = async ({ locals: { supabase }, url }) => {
	// ✅ getUser()로 서버 검증
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		throw redirect(303, '/login');
	}

	const userRepo = new UserRepository(supabase);
	const profile = await userRepo.findById(user.id);

	if (!profile || (profile.role !== 'admin' && profile.role !== 'moderator')) {
		throw redirect(303, '/');
	}

	// Get search and filter parameters
	const search = url.searchParams.get('search') || '';
	const role = url.searchParams.get('role') || '';
	const page = parseInt(url.searchParams.get('page') || '1');
	const limit = 20;
	const offset = (page - 1) * limit;

	// Build query
	let query = supabase
		.from('profiles')
		.select('*', { count: 'exact' })
		.order('created_at', { ascending: false })
		.range(offset, offset + limit - 1);

	// Apply filters
	if (search) {
		query = query.or(`username.ilike.%${search}%,full_name.ilike.%${search}%`);
	}

	if (role && ['user', 'admin', 'moderator'].includes(role)) {
		query = query.eq('role', role);
	}

	const { data: users, count, error } = await query;

	if (error) {
		console.error('유저 목록 조회 에러:', error);
		return {
			users: [],
			total: 0,
			page,
			totalPages: 0,
			search,
			roleFilter: role
		};
	}

	// Get post counts for each user
	const userIds = users?.map(u => u.id) || [];
	const { data: postCounts } = await supabase
		.from('posts')
		.select('author_id')
		.in('author_id', userIds);

	const postCountMap = new Map<string, number>();
	postCounts?.forEach(post => {
		const count = postCountMap.get(post.author_id) || 0;
		postCountMap.set(post.author_id, count + 1);
	});

	// Add post counts to users
	const usersWithStats = users?.map(user => ({
		...user,
		post_count: postCountMap.get(user.id) || 0
	}));

	return {
		users: usersWithStats || [],
		total: count || 0,
		page,
		totalPages: Math.ceil((count || 0) / limit),
		search,
		roleFilter: role
	};
};

export const actions: Actions = {
	// Update user role
	updateRole: async ({ request, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) {
			return fail(401, { error: '로그인이 필요합니다.' });
		}

		const userRepo = new UserRepository(supabase);
		const adminProfile = await userRepo.findById(user.id);

		if (!adminProfile || adminProfile.role !== 'admin') {
			return fail(403, { error: '권한이 없습니다.' });
		}

		const formData = await request.formData();
		const userId = formData.get('userId') as string;
		const newRole = formData.get('role') as 'user' | 'admin' | 'moderator';

		if (!userId || !newRole || !['user', 'admin', 'moderator'].includes(newRole)) {
			return fail(400, { error: '잘못된 요청입니다.' });
		}

		// Can't change own role
		if (userId === user.id) {
			return fail(400, { error: '자신의 권한은 변경할 수 없습니다.' });
		}

		try {
			await userRepo.update(userId, { role: newRole });
			return { success: true, message: '권한이 변경되었습니다.' };
		} catch (error) {
			console.error('권한 변경 에러:', error);
			return fail(500, { error: '권한 변경에 실패했습니다.' });
		}
	},

	// Delete user (soft delete - just change role to 'banned' or delete profile)
	banUser: async ({ request, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) {
			return fail(401, { error: '로그인이 필요합니다.' });
		}

		const userRepo = new UserRepository(supabase);
		const adminProfile = await userRepo.findById(user.id);

		if (!adminProfile || (adminProfile.role !== 'admin' && adminProfile.role !== 'moderator')) {
			return fail(403, { error: '권한이 없습니다.' });
		}

		const formData = await request.formData();
		const userId = formData.get('userId') as string;

		if (!userId) {
			return fail(400, { error: '잘못된 요청입니다.' });
		}

		// Can't ban yourself
		if (userId === user.id) {
			return fail(400, { error: '자신을 차단할 수 없습니다.' });
		}

		try {
			// For now, we'll just update bio to indicate banned status
			// In production, you'd want a proper 'banned' or 'status' field
			await userRepo.update(userId, {
				bio: '[BANNED] ' + (await userRepo.findById(userId))?.bio || ''
			});
			return { success: true, message: '사용자가 차단되었습니다.' };
		} catch (error) {
			console.error('사용자 차단 에러:', error);
			return fail(500, { error: '사용자 차단에 실패했습니다.' });
		}
	}
};
