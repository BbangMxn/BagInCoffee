import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { uploadToR2 } from '$lib/server/storage/r2';
import { validateImageFiles, generateSafeFileName } from '$lib/server/utils/fileValidation';

/**
 * POST /api/upload/post-images
 * 게시물 이미지 업로드 (Cloudflare R2)
 * Enhanced security: validates MIME type, file extension, and file content (magic number)
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	try {
		const formData = await request.formData();
		const images = formData.getAll('images') as File[];

		// Comprehensive validation (count, size, type, content)
		const validation = await validateImageFiles(images);

		if (!validation.valid) {
			const firstError = validation.errors[0];
			if (firstError) {
				return svelteError(400, firstError.error.message);
			}
			return svelteError(400, '유효하지 않은 파일입니다.');
		}

		// Upload validated files
		const uploadedUrls: string[] = [];
		const userId = user.id;

		for (const image of validation.validFiles) {
			// Generate secure filename
			const fileName = generateSafeFileName(image.name, userId);
			const path = `posts/${userId}/${fileName}`;

			// Upload to R2
			const url = await uploadToR2(image, path);
			uploadedUrls.push(url);
		}

		return json({
			success: true,
			urls: uploadedUrls
		});
	} catch (err: any) {
		// Log error message only (not full error object to avoid leaking sensitive info)
		console.error('Post images upload failed:', {
			userId: user.id,
			error: err.message,
			timestamp: new Date().toISOString()
		});
		return svelteError(500, '이미지 업로드에 실패했습니다.');
	}
};
