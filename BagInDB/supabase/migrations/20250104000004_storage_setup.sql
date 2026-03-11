-- ==============================================
-- Storage Buckets Setup
-- ==============================================

-- Brand Images Bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'brand-images',
  'brand-images',
  true,
  10485760, -- 10MB
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- Equipment/Product Images Bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'equipment-images',
  'equipment-images',
  true,
  10485760, -- 10MB
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- ==============================================
-- Storage Policies
-- ==============================================

-- Brand Images Policies
CREATE POLICY "Brand images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'brand-images');

CREATE POLICY "Authenticated users can upload brand images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'brand-images');

CREATE POLICY "Authenticated users can update brand images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'brand-images')
  WITH CHECK (bucket_id = 'brand-images');

CREATE POLICY "Authenticated users can delete brand images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'brand-images');

-- Equipment Images Policies
CREATE POLICY "Equipment images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'equipment-images');

CREATE POLICY "Authenticated users can upload equipment images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'equipment-images');

CREATE POLICY "Authenticated users can update equipment images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'equipment-images')
  WITH CHECK (bucket_id = 'equipment-images');

CREATE POLICY "Authenticated users can delete equipment images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'equipment-images');
