# Cloudflare R2 설정 가이드

## 1. Cloudflare R2 버킷 생성

1. **Cloudflare Dashboard** 접속 (https://dash.cloudflare.com)
2. 왼쪽 메뉴에서 **R2** 클릭
3. **Create bucket** 클릭
4. 버킷 설정:
   - **Bucket name**: `bagincoffee-posts` (또는 원하는 이름)
   - **Location**: Automatic (자동)
5. **Create bucket** 클릭

## 2. API 토큰 생성

1. R2 대시보드에서 **Manage R2 API Tokens** 클릭
2. **Create API Token** 클릭
3. 토큰 설정:
   - **Token name**: `BagInCoffee Posts Upload`
   - **Permissions**:
     - ✅ Object Read & Write
   - **Bucket**: `bagincoffee-posts` (위에서 만든 버킷)
4. **Create API Token** 클릭
5. 다음 정보를 복사하여 보관:
   - **Access Key ID**
   - **Secret Access Key**
   - **Endpoint URL** (예: `https://<account_id>.r2.cloudflarestorage.com`)

## 3. 환경 변수 설정

`.env` 파일에 다음 내용 추가:

```env
# Cloudflare R2 Configuration
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY_ID=your_access_key_id
R2_SECRET_ACCESS_KEY=your_secret_access_key
R2_BUCKET_NAME=bagincoffee-posts
R2_PUBLIC_URL=https://your-custom-domain.com  # 또는 R2 public URL
```

## 4. Public URL 설정 (선택사항)

R2 버킷을 공개로 만들려면:

1. 버킷 설정에서 **Settings** 탭 클릭
2. **Public Access** 섹션에서:
   - **Allow public access** 활성화
3. 또는 Custom Domain 연결:
   - **Custom Domains** 탭
   - 자신의 도메인 추가 (예: `cdn.bagincoffee.com`)

## 5. CORS 설정

버킷에서 **Settings** → **CORS Policy** 추가:

```json
[
  {
    "AllowedOrigins": ["http://localhost:5173", "https://yourdomain.com"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]
```

## 완료!

설정이 완료되면 환경 변수를 `.env` 파일에 추가하고 개발 서버를 재시작하세요.
