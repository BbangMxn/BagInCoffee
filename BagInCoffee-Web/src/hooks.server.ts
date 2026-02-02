import { createServerClient } from '@supabase/ssr';
import { type Handle } from '@sveltejs/kit';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';

export const handle: Handle = async ({ event, resolve }) => {
    // Supabase 클라이언트 생성
    event.locals.supabase = createServerClient(
        PUBLIC_SUPABASE_URL,
        PUBLIC_SUPABASE_ANON_KEY,
        {
            cookies: {
                get: (key) => event.cookies.get(key),
                set: (key, value, options) => {
                    event.cookies.set(key, value, { ...options, path: '/' });
                },
                remove: (key, options) => {
                    event.cookies.delete(key, { ...options, path: '/' });
                },
            },
        }
    );

    /**
     * getSession() - 빠른 세션 확인 (쿠키 기반)
     *
     * 경고: 이 방법은 쿠키에서 직접 세션을 읽으므로 보안에 취약할 수 있습니다.
     * 읽기 전용, UI 표시용으로만 사용하세요.
     *
     * 민감한 작업(생성/수정/삭제)에는 safeGetSession()을 사용하세요.
     */
    event.locals.getSession = async () => {
        // auth.getUser()로 먼저 검증 (보안 권장사항)
        const {
            data: { user }
        } = await event.locals.supabase.auth.getUser();

        if (!user) {
            return null;
        }

        // 검증 후 세션 반환
        const {
            data: { session }
        } = await event.locals.supabase.auth.getSession();

        return session;
    };

    /**
     * safeGetSession() - 안전한 세션 확인 (서버 검증)
     *
     * 서버에 사용자를 검증한 후 세션을 반환합니다.
     * 파일 업로드, 데이터 수정 등 민감한 작업에 사용하세요.
     */
    event.locals.safeGetSession = async () => {
        const {
            data: { user },
            error
        } = await event.locals.supabase.auth.getUser();

        if (error || !user) {
            return { session: null, user: null };
        }

        const {
            data: { session }
        } = await event.locals.supabase.auth.getSession();

        return { session, user };
    };

    return resolve(event);
};
