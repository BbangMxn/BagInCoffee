import { fail, redirect } from '@sveltejs/kit';
import type { Actions } from './$types';
import { UserRepository } from '$lib/server/database/Repository/user.repository';
import { validateImageFile } from '$lib/server/utils/fileValidation';

export const actions: Actions = {
	signup: async ({ request, locals: { supabase }, url }) => {
		const formData = await request.formData();
		const email = formData.get('email') as string;
		const password = formData.get('password') as string;
		const username = formData.get('username') as string;
		const full_name = (formData.get('full_name') as string) || null;
		const bio = (formData.get('bio') as string) || null;
		const location = (formData.get('location') as string) || null;
		const avatarFile = formData.get('avatar') as File | null;

		// Validate username format (한글/영문/숫자/언더스코어 허용)
		const usernameRegex = /^[a-zA-Z0-9_가-힣]{2,20}$/;
		if (!usernameRegex.test(username)) {
			return fail(400, {
				error: '닉네임은 2-20자의 한글, 영문, 숫자, 언더스코어만 사용 가능합니다.',
				email,
				username,
				full_name,
				bio,
				location
			});
		}

		// Check if username is already taken
		const userRepo = new UserRepository(supabase);
		const isAvailable = await userRepo.isUsernameAvailable(username);

		if (!isAvailable) {
			return fail(400, {
				error: '이미 사용 중인 닉네임입니다.',
				email,
				username,
				full_name,
				bio,
				location
			});
		}

		// 1. Supabase Auth에 사용자 등록
		const { data: authData, error: authError } = await supabase.auth.signUp({
			email,
			password,
			options: {
				emailRedirectTo: `${url.origin}/auth/callback`,
			}
		});

		if (authError) {
			return fail(400, {
				error: authError.message,
				email,
				username,
				full_name,
				bio,
				location
			});
		}

		// 2. Auth 사용자가 생성되었으면 프로필 생성
		if (authData.user) {
			try {
				let avatar_url = null;

				// 프로필 사진이 있으면 업로드
				if (avatarFile && avatarFile.size > 0) {
					try {
						// Validate image file (MIME type, extension, magic number)
						const validation = await validateImageFile(avatarFile);

						if (!validation.valid) {
							// Return error if avatar is invalid
							return fail(400, {
								error: validation.error?.message || '유효하지 않은 프로필 이미지입니다.',
								email,
								username,
								full_name,
								bio,
								location
							});
						}

						// Additional size check for avatars (2MB)
						const avatarMaxSize = 2 * 1024 * 1024;
						if (avatarFile.size > avatarMaxSize) {
							return fail(400, {
								error: '프로필 이미지는 2MB 이하여야 합니다.',
								email,
								username,
								full_name,
								bio,
								location
							});
						}

						// Use validated extension
						const fileExt = validation.extension || 'jpg';
						const fileName = `${authData.user.id}/avatar.${fileExt}`;

						// Supabase Storage에 업로드
						const { error: uploadError } = await supabase.storage
							.from('ProfileImages')
							.upload(fileName, avatarFile, {
								cacheControl: '3600',
								upsert: true
							});

						if (uploadError) {
							console.error('Avatar upload failed:', {
								userId: authData.user.id,
								error: uploadError.message,
								timestamp: new Date().toISOString()
							});
						} else {
							// Public URL 생성
							const { data: publicUrlData } = supabase.storage
								.from('ProfileImages')
								.getPublicUrl(fileName);

							avatar_url = publicUrlData.publicUrl;
						}
					} catch (uploadError: any) {
						console.error('Avatar upload error:', {
							userId: authData.user.id,
							error: uploadError.message,
							timestamp: new Date().toISOString()
						});
						// 업로드 실패해도 계정 생성은 진행
					}
				}

				// 프로필 정보와 함께 생성
				await userRepo.create(authData.user.id, {
					username,
					full_name: full_name || username, // 이름이 없으면 닉네임 사용
					avatar_url,
					bio,
					location,
					website: null
				});
			} catch (error: any) {
				console.error('Profile creation failed:', {
					error: error.message,
					timestamp: new Date().toISOString()
				});
				return fail(500, {
					error: '프로필 생성에 실패했습니다. 다시 시도해주세요.',
					email,
					username,
					full_name,
					bio,
					location
				});
			}
		}

		return {
			success: true
		};
	},

	// Google 회원가입
	google: async ({ locals: { supabase }, url }) => {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'google',
			options: {
				redirectTo: `${url.origin}/auth/callback`
			}
		});

		if (error) {
			return fail(400, { error: error.message });
		}

		if (data.url) {
			throw redirect(303, data.url);
		}
	},

	// Kakao 회원가입
	kakao: async ({ locals: { supabase }, url }) => {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'kakao',
			options: {
				redirectTo: `${url.origin}/auth/callback`
			}
		});

		if (error) {
			return fail(400, { error: error.message });
		}

		if (data.url) {
			throw redirect(303, data.url);
		}
	},

	// GitHub 회원가입
	github: async ({ locals: { supabase }, url }) => {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'github',
			options: {
				redirectTo: `${url.origin}/auth/callback`
			}
		});

		if (error) {
			return fail(400, { error: error.message });
		}

		if (data.url) {
			throw redirect(303, data.url);
		}
	}
};
