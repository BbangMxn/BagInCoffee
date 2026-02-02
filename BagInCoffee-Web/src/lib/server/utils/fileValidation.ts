/**
 * File validation utilities with magic number (file signature) checking
 * Provides robust file type validation beyond MIME type checking
 */

/**
 * File type signatures (magic numbers)
 * First few bytes of files that identify the file type
 */
const FILE_SIGNATURES = {
	// JPEG
	jpeg: [
		[0xff, 0xd8, 0xff, 0xe0], // JPEG/JFIF
		[0xff, 0xd8, 0xff, 0xe1], // JPEG/EXIF
		[0xff, 0xd8, 0xff, 0xe2], // JPEG
		[0xff, 0xd8, 0xff, 0xe3], // JPEG
		[0xff, 0xd8, 0xff, 0xe8]  // JPEG
	],
	// PNG
	png: [[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]],
	// GIF
	gif: [
		[0x47, 0x49, 0x46, 0x38, 0x37, 0x61], // GIF87a
		[0x47, 0x49, 0x46, 0x38, 0x39, 0x61]  // GIF89a
	],
	// WebP
	webp: [[0x52, 0x49, 0x46, 0x46, null, null, null, null, 0x57, 0x45, 0x42, 0x50]]
} as const;

/**
 * Allowed image types configuration
 */
export const ALLOWED_IMAGE_TYPES = {
	mimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'] as const,
	extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'] as const,
	maxSize: 5 * 1024 * 1024, // 5MB
	maxCount: 10
} as const;

export type AllowedMimeType = (typeof ALLOWED_IMAGE_TYPES.mimeTypes)[number];
export type AllowedExtension = (typeof ALLOWED_IMAGE_TYPES.extensions)[number];

/**
 * File validation error types
 */
export class FileValidationError extends Error {
	constructor(
		message: string,
		public code: string
	) {
		super(message);
		this.name = 'FileValidationError';
	}
}

/**
 * Check if bytes match a signature pattern
 * null in signature means "any byte"
 */
function matchesSignature(bytes: Uint8Array, signature: readonly (number | null)[]): boolean {
	if (bytes.length < signature.length) return false;

	for (let i = 0; i < signature.length; i++) {
		if (signature[i] !== null && bytes[i] !== signature[i]) {
			return false;
		}
	}
	return true;
}

/**
 * Detect file type from file header (magic number)
 * More reliable than MIME type which can be spoofed
 */
async function detectFileType(file: File): Promise<string | null> {
	const buffer = await file.slice(0, 12).arrayBuffer();
	const bytes = new Uint8Array(buffer);

	// Check each known signature
	for (const [type, signatures] of Object.entries(FILE_SIGNATURES)) {
		for (const signature of signatures) {
			if (matchesSignature(bytes, signature as readonly (number | null)[])) {
				return type;
			}
		}
	}

	return null;
}

/**
 * Validate file extension
 */
function validateExtension(fileName: string): AllowedExtension | null {
	const ext = fileName.split('.').pop()?.toLowerCase();
	if (!ext) return null;

	return ALLOWED_IMAGE_TYPES.extensions.includes(ext as AllowedExtension)
		? (ext as AllowedExtension)
		: null;
}

/**
 * Validate MIME type
 */
function validateMimeType(mimeType: string): boolean {
	return ALLOWED_IMAGE_TYPES.mimeTypes.includes(mimeType as AllowedMimeType);
}

/**
 * Comprehensive image file validation
 * Checks: file size, MIME type, extension, and actual file content (magic number)
 */
export async function validateImageFile(file: File): Promise<{
	valid: boolean;
	extension: AllowedExtension | null;
	detectedType: string | null;
	error?: FileValidationError;
}> {
	// 1. Check file size
	if (file.size === 0) {
		return {
			valid: false,
			extension: null,
			detectedType: null,
			error: new FileValidationError('파일이 비어있습니다.', 'EMPTY_FILE')
		};
	}

	if (file.size > ALLOWED_IMAGE_TYPES.maxSize) {
		const sizeMB = (ALLOWED_IMAGE_TYPES.maxSize / (1024 * 1024)).toFixed(0);
		return {
			valid: false,
			extension: null,
			detectedType: null,
			error: new FileValidationError(
				`파일 크기는 ${sizeMB}MB 이하여야 합니다.`,
				'FILE_TOO_LARGE'
			)
		};
	}

	// 2. Validate MIME type
	if (!validateMimeType(file.type)) {
		return {
			valid: false,
			extension: null,
			detectedType: null,
			error: new FileValidationError(
				'지원하지 않는 파일 형식입니다. (JPEG, PNG, GIF, WebP만 허용)',
				'INVALID_MIME_TYPE'
			)
		};
	}

	// 3. Validate file extension
	const extension = validateExtension(file.name);
	if (!extension) {
		return {
			valid: false,
			extension: null,
			detectedType: null,
			error: new FileValidationError(
				'지원하지 않는 파일 확장자입니다.',
				'INVALID_EXTENSION'
			)
		};
	}

	// 4. Validate actual file content (magic number)
	const detectedType = await detectFileType(file);
	if (!detectedType) {
		return {
			valid: false,
			extension,
			detectedType: null,
			error: new FileValidationError(
				'유효하지 않은 이미지 파일입니다.',
				'INVALID_FILE_CONTENT'
			)
		};
	}

	// 5. Check if detected type matches extension
	const normalizedExtension = extension === 'jpg' ? 'jpeg' : extension;
	if (detectedType !== normalizedExtension && detectedType !== 'webp') {
		// WebP is more lenient as some tools may save with wrong extension
		if (normalizedExtension !== 'webp') {
			return {
				valid: false,
				extension,
				detectedType,
				error: new FileValidationError(
					'파일 확장자와 실제 파일 형식이 일치하지 않습니다.',
					'EXTENSION_MISMATCH'
				)
			};
		}
	}

	return {
		valid: true,
		extension,
		detectedType
	};
}

/**
 * Validate multiple image files
 */
export async function validateImageFiles(
	files: File[]
): Promise<{
	valid: boolean;
	validFiles: File[];
	errors: { file: File; error: FileValidationError }[];
}> {
	// Check file count
	if (files.length === 0) {
		return {
			valid: false,
			validFiles: [],
			errors: [
				{
					file: new File([], ''),
					error: new FileValidationError('업로드할 파일이 없습니다.', 'NO_FILES')
				}
			]
		};
	}

	if (files.length > ALLOWED_IMAGE_TYPES.maxCount) {
		return {
			valid: false,
			validFiles: [],
			errors: [
				{
					file: new File([], ''),
					error: new FileValidationError(
						`최대 ${ALLOWED_IMAGE_TYPES.maxCount}개의 이미지만 업로드할 수 있습니다.`,
						'TOO_MANY_FILES'
					)
				}
			]
		};
	}

	// Validate each file
	const results = await Promise.all(files.map((file) => validateImageFile(file)));

	const validFiles: File[] = [];
	const errors: { file: File; error: FileValidationError }[] = [];

	results.forEach((result, index) => {
		if (result.valid) {
			validFiles.push(files[index]);
		} else if (result.error) {
			errors.push({
				file: files[index],
				error: result.error
			});
		}
	});

	return {
		valid: errors.length === 0,
		validFiles,
		errors
	};
}

/**
 * Generate safe filename with sanitization
 */
export function generateSafeFileName(originalName: string, userId: string): string {
	// Extract extension
	const ext = originalName.split('.').pop()?.toLowerCase() || 'jpg';

	// Validate extension
	if (!ALLOWED_IMAGE_TYPES.extensions.includes(ext as AllowedExtension)) {
		throw new FileValidationError('Invalid file extension', 'INVALID_EXTENSION');
	}

	// Generate random UUID-based filename
	const timestamp = Date.now();
	const random = Math.random().toString(36).substring(2, 15);

	return `${userId}_${timestamp}_${random}.${ext}`;
}
