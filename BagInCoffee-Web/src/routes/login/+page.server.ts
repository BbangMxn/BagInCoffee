import { fail, redirect } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
    // 이메일/비밀번호 로그인
    login: async ({ request, locals: { supabase } }) => {
        const formData = await request.formData();
        const email = formData.get('email') as string;
        const password = formData.get('password') as string;

        const { error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            return fail(400, {
                error: '이메일 또는 비밀번호가 올바르지 않습니다.',
                email
            });
        }

        throw redirect(303, '/');
    },

    // Google 소셜 로그인
    google: async ({ locals: { supabase }, url }) => {
        const { data, error } = await supabase.auth.signInWithOAuth({
            provider: 'google',
            options: {
                redirectTo: `${url.origin}/auth/callback`
            }
        });

        if (error) {
            return fail(400, {
                error: error.message
            });
        }

        if (data.url) {
            throw redirect(303, data.url);
        }
    },

    // Kakao 소셜 로그인
    kakao: async ({ locals: { supabase }, url }) => {
        const { data, error } = await supabase.auth.signInWithOAuth({
            provider: 'kakao',
            options: {
                redirectTo: `${url.origin}/auth/callback`
            }
        });

        if (error) {
            return fail(400, {
                error: error.message
            });
        }

        if (data.url) {
            throw redirect(303, data.url);
        }
    },

    // GitHub 소셜 로그인
    github: async ({ locals: { supabase }, url }) => {
        const { data, error } = await supabase.auth.signInWithOAuth({
            provider: 'github',
            options: {
                redirectTo: `${url.origin}/auth/callback`
            }
        });

        if (error) {
            return fail(400, {
                error: error.message
            });
        }

        if (data.url) {
            throw redirect(303, data.url);
        }
    }
};
