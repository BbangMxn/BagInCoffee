import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { uploadEquipmentImage, deleteStorageFile, extractPathFromUrl } from '$lib/utils/storage';

/**
 * POST /api/equipment/upload
 * 장비 이미지 업로드 (관리자만)
 * Content-Type: multipart/form-data
 *
 * FormData fields:
 * - file: File (이미지 파일)
 * - equipmentId?: string (선택, 장비 ID)
 * - oldImageUrl?: string (선택, 교체할 기존 이미지 URL)
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
		const equipmentId = formData.get('equipmentId') as string | null;
		const oldImageUrl = formData.get('oldImageUrl') as string | null;

		if (!file) {
			return svelteError(400, 'File is required');
		}

		// 파일 타입 검증
		const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
		if (!allowedTypes.includes(file.type)) {
			return svelteError(400, 'Invalid file type. Allowed: JPG, PNG, WebP');
		}

		// 파일 크기 검증 (10MB)
		const MAX_SIZE = 10 * 1024 * 1024;
		if (file.size > MAX_SIZE) {
			return svelteError(400, 'File size must be less than 10MB');
		}

		// 스토리지에 업로드
		const uploadResult = await uploadEquipmentImage(supabase, file, equipmentId || undefined);

		if (!uploadResult.success) {
			return svelteError(500, uploadResult.error || 'Upload failed');
		}

		// 기존 이미지 삭제 (새 이미지 업로드 성공 후)
		if (oldImageUrl && uploadResult.publicUrl !== oldImageUrl) {
			const oldPath = extractPathFromUrl(oldImageUrl);
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
		console.error('Equipment image upload error:', err);
		return svelteError(500, err.message || 'Upload failed');
	}
};
