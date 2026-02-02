import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { supabase } }) => {
	// 개발자 공지사항 가져오기
	// PostgreSQL의 @> 연산자를 사용하여 두 태그를 모두 포함하는 게시물 조회
	const { data: announcements } = await supabase
		.from('posts')
		.select(`
			id,
			content,
			images,
			created_at,
			updated_at,
			profiles:user_id (
				id,
				full_name,
				avatar_url,
				role
			)
		`)
		.contains('tags', ['developer', 'announcement'])
		.order('created_at', { ascending: false })
		.limit(20);

	return {
		announcements: announcements || []
	};
};
