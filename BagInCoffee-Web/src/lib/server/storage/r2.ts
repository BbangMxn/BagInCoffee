import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { env } from '$env/dynamic/private';

/**
 * Cloudflare R2 클라이언트
 * S3 호환 API를 사용
 */
export const r2Client = new S3Client({
	region: 'auto',
	endpoint: `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
	credentials: {
		accessKeyId: env.R2_ACCESS_KEY_ID,
		secretAccessKey: env.R2_SECRET_ACCESS_KEY,
	},
});

/**
 * R2에 파일 업로드
 * @param file - 업로드할 파일
 * @param path - 저장 경로 (예: posts/user_id/image.jpg)
 * @returns 업로드된 파일의 공개 URL
 */
export async function uploadToR2(file: File, path: string): Promise<string> {
	const buffer = await file.arrayBuffer();

	const command = new PutObjectCommand({
		Bucket: env.R2_BUCKET_NAME,
		Key: path,
		Body: Buffer.from(buffer),
		ContentType: file.type,
	});

	await r2Client.send(command);

	// 공개 URL 반환
	return `${env.R2_PUBLIC_URL}/${path}`;
}

/**
 * R2에서 파일 삭제
 * @param path - 삭제할 파일 경로
 */
export async function deleteFromR2(path: string): Promise<void> {
	const command = new DeleteObjectCommand({
		Bucket: env.R2_BUCKET_NAME,
		Key: path,
	});

	await r2Client.send(command);
}

/**
 * URL에서 R2 경로 추출
 * @param url - R2 공개 URL
 * @returns 파일 경로
 */
export function getR2PathFromUrl(url: string): string {
	return url.replace(`${env.R2_PUBLIC_URL}/`, '');
}
