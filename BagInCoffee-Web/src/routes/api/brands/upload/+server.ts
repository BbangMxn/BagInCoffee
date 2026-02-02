import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { uploadBrandLogo, deleteStorageFile, extractPathFromUrl } from '$lib/utils/storage';

/**
 * POST /api/brands/upload
 * 브랜드 로고 이미지 업로드 (관리자만)
 * Content-Type: multipart/form-data
 *
 * FormData fields:
 * - file: File (이미지 파일)
 * - brandId?: string (선택, 브랜드 ID)
 * - oldLogoUrl?: string (선택, 교체할 기존 로고 URL)
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	// 관리자 권한 체크
	const { data: profile } = await supabase
		.from('profiles')
		.select('role')
		.eq('id', user.id)
		.single();

	if (profile?.role !== 'admin' && profile?.role !== 'moderator') {
		return svelteError(403, 'Admin or moderator only');
	}

	try {
		const formData = await request.formData();
		const file = formData.get('file') as File;
		const brandId = formData.get('brandId') as string | null;
		const oldLogoUrl = formData.get('oldLogoUrl') as string | null;

		if (!file) {
			return svelteError(400, 'File is required');
		}

		// 파일 타입 검증
		const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/svg+xml'];
		if (!allowedTypes.includes(file.type)) {
			return svelteError(400, 'Invalid file type. Allowed: JPG, PNG, WebP, SVG');
		}

		// 파일 크기 검증 (5MB)
		const MAX_SIZE = 5 * 1024 * 1024;
		if (file.size > MAX_SIZE) {
			return svelteError(400, 'File size must be less than 5MB');
		}

		// 스토리지에 업로드
		const uploadResult = await uploadBrandLogo(supabase, file, brandId || undefined);

		if (!uploadResult.success) {
			return svelteError(500, uploadResult.error || 'Upload failed');
		}

		// 기존 로고 삭제 (새 로고 업로드 성공 후)
		if (oldLogoUrl && uploadResult.publicUrl !== oldLogoUrl) {
			const oldPath = extractPathFromUrl(oldLogoUrl);
			if (oldPath) {
				await deleteStorageFile(supabase, oldPath);
			}
		}

		return json({
			success: true,
			data: {
				url: uploadResult.publicUrl,
				path: uploadResult.path
			}
		});
	} catch (err: any) {
		console.error('Brand logo upload error:', err);
		return svelteError(500, err.message || 'Upload failed');
	}
};
