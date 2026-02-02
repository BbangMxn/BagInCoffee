import { redirect, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';
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

export const actions: Actions = {
	updateProfile: async ({ request, locals: { supabase } }) => {
		// ✅ getUser()로 서버 검증
		const { data: { user } } = await supabase.auth.getUser();

		if (!user) {
			throw redirect(303, '/login');
		}

		const formData = await request.formData();
		const username = formData.get('username') as string;
		const full_name = formData.get('full_name') as string;
		const bio = formData.get('bio') as string;
		const location = formData.get('location') as string;
		const website = formData.get('website') as string;

		const userRepo = new UserRepository(supabase);

		// username이 변경되었다면 중복 체크
		if (username) {
			const currentProfile = await userRepo.findById(user.id);
			if (currentProfile.username !== username) {
				const isAvailable = await userRepo.isUsernameAvailable(username);
				if (!isAvailable) {
					return fail(400, {
						error: '이미 사용 중인 사용자명입니다.',
						username,
						full_name,
						bio,
						location,
						website
					});
				}
			}
		}

		try {
			await userRepo.update(user.id, {
				username: username || null,
				full_name: full_name || null,
				bio: bio || null,
				location: location || null,
				website: website || null
			});
		} catch (error: any) {
			console.error('프로필 업데이트 에러:', error);
			return fail(400, {
				error: error.message || '프로필 업데이트에 실패했습니다.',
				username,
				full_name,
				bio,
				location,
				website
			});
		}

		// 성공 시 프로필 페이지로 리디렉션
		throw redirect(303, '/profile');
	}
};
