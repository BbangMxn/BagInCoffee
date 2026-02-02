import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { UserRepository } from '$lib/server/database/Repository/user.repository';

export const load: PageServerLoad = async ({ locals: { supabase } }) => {
	// ✅ getUser()로 서버 검증
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		throw redirect(303, '/login');
	}

	const userRepo = new UserRepository(supabase);

	try {
		const profile = await userRepo.findById(user.id);
		const { data: { session } } = await supabase.auth.getSession();
		return {
			profile,
			session
		};
	} catch (error) {
		console.error('프로필 로드 실패:', error);
		throw redirect(303, '/');
	}
};
