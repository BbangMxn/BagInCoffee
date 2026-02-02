/**
 * 사용자 프로필 정보
 * @table profiles
 * @rls Enabled
 */
export interface UserProfile {
	/** 사용자 고유 ID */
	id: string;

	/** 사용자명 (고유값) */
	username: string | null;

	/** 전체 이름 */
	full_name: string | null;

	/** 프로필 이미지 URL */
	avatar_url: string | null;

	/** 커버 이미지 URL */
	cover_image_url: string | null;

	/** 자기소개 */
	bio: string | null;

	/** 위치 정보 */
	location: string | null;

	/** 웹사이트 URL */
	website: string | null;

	/** 사용자 권한 */
	role: 'user' | 'admin' | 'moderator';

	/** 아바타 수정 일시 */
	avatar_updated_at: string;

	/** 생성 일시 */
	created_at: string;

	/** 수정 일시 */
	updated_at: string;
}

/**
 * 간단한 사용자 프로필 (리스트/카드용)
 */
export interface UserProfileSimple {
	id: string;
	username: string | null;
	full_name: string | null;
	avatar_url: string | null;
}
