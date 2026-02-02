-- ============================================
-- Supabase Storage 설정: ProfileImages 버킷
-- ============================================

-- 1. 모든 사용자가 프로필 이미지를 볼 수 있도록 (Public Read)
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
USING ( bucket_id = 'ProfileImages' );

-- 2. 로그인한 사용자는 자신의 폴더에 업로드 가능
-- 파일 경로: {user_id}/avatar.jpg 형식
CREATE POLICY "Users can upload own profile image"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'ProfileImages'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 3. 로그인한 사용자는 자신의 이미지 업데이트 가능
CREATE POLICY "Users can update own profile image"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'ProfileImages'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 4. 로그인한 사용자는 자신의 이미지 삭제 가능
CREATE POLICY "Users can delete own profile image"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'ProfileImages'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ============================================
-- 설명:
-- - 모든 사람이 프로필 이미지를 볼 수 있습니다 (공개)
-- - 사용자는 자신의 폴더(user_id)에만 이미지를 업로드/수정/삭제할 수 있습니다
-- - 파일 경로 예시: ProfileImages/{user_id}/avatar.jpg
-- ============================================
