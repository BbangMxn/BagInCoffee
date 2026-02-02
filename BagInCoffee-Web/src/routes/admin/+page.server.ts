import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { UserRepository } from '$lib/server/database/Repository/user.repository';
import { PostRepository } from '$lib/server/database/Repository/post.repository';

export const load: PageServerLoad = async ({ locals: { supabase } }) => {
	// ✅ getUser()로 서버 검증
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		throw redirect(303, '/login');
	}

	const userRepo = new UserRepository(supabase);

	try {
		const profile = await userRepo.findById(user.id);

		// 관리자 권한 체크
		if (profile.role !== 'admin' && profile.role !== 'moderator') {
			throw redirect(303, '/'); // 권한 없으면 홈으로
		}

		const postRepo = new PostRepository(supabase);

		// 통계 데이터 수집
		const { data: usersCount } = await supabase
			.from('profiles')
			.select('*', { count: 'exact', head: true });

		const { data: postsCount } = await supabase
			.from('posts')
			.select('*', { count: 'exact', head: true });

		// 최근 가입 사용자
		const { data: recentUsers } = await supabase
			.from('profiles')
			.select('id, username, full_name, avatar_url, role, created_at')
			.order('created_at', { ascending: false })
			.limit(10);

		// 최근 게시물
		const recentPosts = await postRepo.findFeed(1, 10);

		return {
			profile,
			stats: {
				usersCount: usersCount?.length || 0,
				postsCount: postsCount?.length || 0
			},
			recentUsers: recentUsers || [],
			recentPosts: recentPosts.posts || []
		};
	} catch (error) {
		console.error('관리자 페이지 로드 실패:', error);
		throw redirect(303, '/');
	}
};
