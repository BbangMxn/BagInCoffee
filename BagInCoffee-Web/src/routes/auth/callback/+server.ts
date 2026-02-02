import { redirect } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const code = url.searchParams.get('code');

	if (code) {
		// OAuth code를 session으로 교환
		const { error } = await supabase.auth.exchangeCodeForSession(code);

		if (error) {
			console.error('OAuth error:', error);
			throw redirect(303, '/login?error=oauth_failed');
		}
	}

	// 로그인 성공 후 홈으로 이동
	throw redirect(303, '/');
};
