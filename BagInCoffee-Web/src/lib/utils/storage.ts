import type { SupabaseClient } from '@supabase/supabase-js';

/**
 * Supabase Storage 헬퍼 함수
 * equipment 버킷을 사용하여 이미지 업로드/삭제 관리
 */

const BUCKET_NAME = 'equipment';

export interface UploadResult {
	success: boolean;
	publicUrl?: string;
	path?: string;
	error?: string;
}

/**
 * 파일 확장자 추출
 */
function getFileExtension(filename: string): string {
	const parts = filename.split('.');
	return parts.length > 1 ? parts[parts.length - 1].toLowerCase() : '';
}

/**
 * 고유한 파일명 생성
 */
function generateUniqueFileName(originalName: string, prefix: string = ''): string {
	const ext = getFileExtension(originalName);
	const timestamp = Date.now();
	const random = Math.random().toString(36).substring(2, 15);
	const baseName = prefix ? `${prefix}_` : '';
	return `${baseName}${timestamp}_${random}.${ext}`;
}

/**
 * 브랜드 로고 업로드
 * @param supabase - Supabase 클라이언트
 * @param file - 업로드할 파일
 * @param brandId - 브랜드 ID (선택, 파일명에 사용)
 * @returns 업로드 결과 (publicUrl 포함)
 */
export async function uploadBrandLogo(
	supabase: SupabaseClient,
	file: File,
	brandId?: string
): Promise<UploadResult> {
	try {
		// 파일 검증
		if (!file) {
			return { success: false, error: '파일이 선택되지 않았습니다.' };
		}

		// 파일 크기 제한 (5MB)
		const MAX_SIZE = 5 * 1024 * 1024;
		if (file.size > MAX_SIZE) {
			return { success: false, error: '파일 크기는 5MB 이하여야 합니다.' };
		}

		// 허용된 이미지 형식
		const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/svg+xml'];
		if (!allowedTypes.includes(file.type)) {
			return {
				success: false,
				error: '허용된 이미지 형식: JPG, PNG, WebP, SVG'
			};
		}

		// 파일명 생성
		const prefix = brandId ? `brand_${brandId}` : 'brand';
		const fileName = generateUniqueFileName(file.name, prefix);
		const filePath = `brands/${fileName}`;

		// 스토리지에 업로드
		const { data, error } = await supabase.storage.from(BUCKET_NAME).upload(filePath, file, {
			cacheControl: '3600',
			upsert: false
		});

		if (error) {
			console.error('Storage upload error:', error);
			return { success: false, error: `업로드 실패: ${error.message}` };
		}

		// Public URL 생성
		const {
			data: { publicUrl }
		} = supabase.storage.from(BUCKET_NAME).getPublicUrl(filePath);

		return {
			success: true,
			publicUrl,
			path: filePath
		};
	} catch (err: any) {
		console.error('uploadBrandLogo error:', err);
		return { success: false, error: err.message || '업로드 중 오류가 발생했습니다.' };
	}
}

/**
 * 장비 이미지 업로드
 * @param supabase - Supabase 클라이언트
 * @param file - 업로드할 파일
 * @param equipmentId - 장비 ID (선택, 파일명에 사용)
 * @returns 업로드 결과 (publicUrl 포함)
 */
export async function uploadEquipmentImage(
	supabase: SupabaseClient,
	file: File,
	equipmentId?: string
): Promise<UploadResult> {
	try {
		// 파일 검증
		if (!file) {
			return { success: false, error: '파일이 선택되지 않았습니다.' };
		}

		// 파일 크기 제한 (10MB)
		const MAX_SIZE = 10 * 1024 * 1024;
		if (file.size > MAX_SIZE) {
			return { success: false, error: '파일 크기는 10MB 이하여야 합니다.' };
		}

		// 허용된 이미지 형식
		const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
		if (!allowedTypes.includes(file.type)) {
			return {
				success: false,
				error: '허용된 이미지 형식: JPG, PNG, WebP'
			};
		}

		// 파일명 생성
		const prefix = equipmentId ? `equipment_${equipmentId}` : 'equipment';
		const fileName = generateUniqueFileName(file.name, prefix);
		const filePath = `equipment/${fileName}`;

		// 스토리지에 업로드
		const { data, error } = await supabase.storage.from(BUCKET_NAME).upload(filePath, file, {
			cacheControl: '3600',
			upsert: false
		});

		if (error) {
			console.error('Storage upload error:', error);
			return { success: false, error: `업로드 실패: ${error.message}` };
		}

		// Public URL 생성
		const {
			data: { publicUrl }
		} = supabase.storage.from(BUCKET_NAME).getPublicUrl(filePath);

		return {
			success: true,
			publicUrl,
			path: filePath
		};
	} catch (err: any) {
		console.error('uploadEquipmentImage error:', err);
		return { success: false, error: err.message || '업로드 중 오류가 발생했습니다.' };
	}
}

/**
 * 스토리지에서 파일 삭제
 * @param supabase - Supabase 클라이언트
 * @param path - 파일 경로 (예: 'brands/brand_123_xxx.jpg')
 * @returns 삭제 성공 여부
 */
export async function deleteStorageFile(
	supabase: SupabaseClient,
	path: string
): Promise<{ success: boolean; error?: string }> {
	try {
		if (!path) {
			return { success: false, error: '파일 경로가 제공되지 않았습니다.' };
		}

		const { error } = await supabase.storage.from(BUCKET_NAME).remove([path]);

		if (error) {
			console.error('Storage delete error:', error);
			return { success: false, error: `삭제 실패: ${error.message}` };
		}

		return { success: true };
	} catch (err: any) {
		console.error('deleteStorageFile error:', err);
		return { success: false, error: err.message || '삭제 중 오류가 발생했습니다.' };
	}
}

/**
 * URL에서 스토리지 경로 추출
 * @param url - Supabase public URL
 * @returns 파일 경로 (예: 'brands/brand_123_xxx.jpg')
 */
export function extractPathFromUrl(url: string): string | null {
	try {
		if (!url) return null;

		// URL에서 equipment 버킷 이후의 경로 추출
		const bucketPattern = new RegExp(`/storage/v1/object/public/${BUCKET_NAME}/(.+)$`);
		const match = url.match(bucketPattern);

		return match ? match[1] : null;
	} catch {
		return null;
	}
}
