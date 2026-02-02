import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals: { supabase } }) => {
	// ✅ getUser()로 서버 검증
	const { data: { user } } = await supabase.auth.getUser();

	// 로그인한 경우 세션과 프로필 정보 가져오기
	let session = null;
	let profile = null;

	if (user) {
		const { data: { session: currentSession } } = await supabase.auth.getSession();
		session = currentSession;

		const { data } = await supabase
			.from('profiles')
			.select('id, username, full_name, avatar_url, bio, location, website, role, created_at')
			.eq('id', user.id)
			.single();

		profile = data;
	}

	return {
		session,
		profile
	};
};
