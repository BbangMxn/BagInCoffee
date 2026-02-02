import type { UserProfile } from '$lib/types/user';
import type { SupabaseClient } from '@supabase/supabase-js';


export class UserRepository {
    constructor(private supabase: SupabaseClient) { }

    async findById(userId: string) {
        const { data, error } = await this.supabase
            .from('profiles')           // 테이블명
            .select('*')                // 모든 컬럼
            .eq('id', userId)           // WHERE id = userId
            .single();                  // 단일 결과 (없으면 에러)

        if (error) throw error;
        return data as UserProfile;
    }
    async findByUsername(username: string) {
        const { data, error } = await this.supabase
            .from('profiles')
            .select('*')
            .eq('username', username)
            .single();
        if (error && error.code !== 'PGRST116') throw error;
        return data as UserProfile | null;
    }
    /**
     * 새로운 사용자 프로필 생성
     * 회원가입 시 호출되어 기본 프로필을 초기화합니다
     * @param userId - Supabase Auth User ID
     * @param profile - 선택적 프로필 정보 (username, full_name 등)
     * @returns 생성된 UserProfile
     */
    async create(userId: string, profile: Partial<UserProfile> = {}) {
        const { data, error } = await this.supabase
            .from('profiles')
            .insert({
                id: userId,                           // auth.users.id와 동일
                username: profile.username ?? null,   // 사용자명 (미설정 시 null)
                full_name: profile.full_name ?? null, // 이름 (미설정 시 null)
                avatar_url: profile.avatar_url ?? null, // 프로필 이미지 (미설정 시 null)
                bio: profile.bio ?? null,             // 자기소개 (미설정 시 null)
                location: profile.location ?? null,   // 위치 (미설정 시 null)
                website: profile.website ?? null,     // 웹사이트 (미설정 시 null)
                role: 'user'                          // 기본 권한은 항상 'user'
            })
            .select()               // 생성된 데이터 반환
            .single();

        if (error) throw error;
        return data as UserProfile;
    }
    async update(userId: string, updates: Partial<UserProfile>) {
        const { data, error } = await this.supabase
            .from('profiles')
            .update({
                ...updates,
                updated_at: new Date().toISOString()  // 수정 시간 자동 갱신
            })
            .eq('id', userId)           // WHERE id = userId
            .select()
            .single();

        if (error) throw error;
        return data as UserProfile;
    }
    async isUsernameAvailable(username: string): Promise<boolean> {
        const { count } = await this.supabase
            .from('profiles')
            .select('*', { count: 'exact', head: true })  // 개수만 조회
            .eq('username', username);

        return count === 0;  // 0개면 사용 가능
    }

    async search(query: string, limit = 10) {
        const { data, error } = await this.supabase
            .from('profiles')
            .select('id, username, full_name, avatar_url')  // 필요한 필드만
            .or(`username.ilike.%${query}%,full_name.ilike.%${query}%`)  // LIKE 검색
            .limit(limit);

        if (error) throw error;
        return data;
    }

}