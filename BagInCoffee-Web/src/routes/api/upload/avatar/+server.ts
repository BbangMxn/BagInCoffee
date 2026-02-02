import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { UserRepository } from '$lib/server/database/Repository/user.repository';
import { validateImageFile, ALLOWED_IMAGE_TYPES } from '$lib/server/utils/fileValidation';

/**
 * POST /api/upload/avatar
 * 프로필 이미지 업로드
 * Enhanced security: validates MIME type, file extension, and file content (magic number)
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	try {
		const formData = await request.formData();
		const file = formData.get('avatar') as File;

		if (!file) {
			return svelteError(400, '파일이 제공되지 않았습니다.');
		}

		// Comprehensive validation (MIME type, extension, magic number, size)
		const validation = await validateImageFile(file);

		if (!validation.valid) {
			return svelteError(400, validation.error?.message || '유효하지 않은 파일입니다.');
		}

		// Additional size check for avatars (2MB limit, stricter than posts)
		const avatarMaxSize = 2 * 1024 * 1024; // 2MB
		if (file.size > avatarMaxSize) {
			return svelteError(400, '프로필 이미지는 2MB 이하여야 합니다.');
		}

		const userId = user.id;
		const fileExt = validation.extension || 'jpg';
		const fileName = `${userId}/avatar.${fileExt}`;

		// 기존 이미지 삭제 (있다면)
		const { data: existingFiles } = await supabase.storage
			.from('ProfileImages')
			.list(userId);

		if (existingFiles && existingFiles.length > 0) {
			const filesToDelete = existingFiles.map(f => `${userId}/${f.name}`);
			await supabase.storage
				.from('ProfileImages')
				.remove(filesToDelete);
		}

		// 새 이미지 업로드
		const { data: uploadData, error: uploadError } = await supabase.storage
			.from('ProfileImages')
			.upload(fileName, file, {
				cacheControl: '3600',
				upsert: true
			});

		if (uploadError) {
			console.error('Upload error:', uploadError);
			return svelteError(500, 'Failed to upload image');
		}

		// Public URL 가져오기
		const { data: urlData } = supabase.storage
			.from('ProfileImages')
			.getPublicUrl(fileName);

		// 프로필에 avatar_url 업데이트
		const userRepo = new UserRepository(supabase);
		await userRepo.update(userId, {
			avatar_url: urlData.publicUrl
		});

		return json({
			success: true,
			avatar_url: urlData.publicUrl
		});

	} catch (err: any) {
		// Log error message only (not full error object to avoid leaking sensitive info)
		console.error('Avatar upload failed:', {
			userId: user.id,
			error: err.message,
			timestamp: new Date().toISOString()
		});
		return svelteError(500, '프로필 이미지 업로드에 실패했습니다.');
	}
};
