# 🚀 Vercel 배포 가이드

BagInCoffee를 Vercel에 배포하는 방법입니다.

## 📋 사전 준비사항

### 1. 필수 계정
- ✅ [Vercel 계정](https://vercel.com) (GitHub 연동 권장)
- ✅ [Supabase 프로젝트](https://supabase.com)
- ✅ [Cloudflare 계정](https://cloudflare.com) (R2 사용)

### 2. 필요한 환경 변수
아래 값들을 준비하세요:

#### Supabase
- `PUBLIC_SUPABASE_URL`: Supabase 프로젝트 URL
- `PUBLIC_SUPABASE_ANON_KEY`: Supabase Anon Key

#### Cloudflare R2
- `R2_ACCOUNT_ID`: Cloudflare Account ID
- `R2_ACCESS_KEY_ID`: R2 Access Key ID
- `R2_SECRET_ACCESS_KEY`: R2 Secret Access Key
- `R2_BUCKET_NAME`: R2 Bucket 이름
- `R2_PUBLIC_URL`: R2 Public URL

## 🌐 Vercel 배포 방법

### 방법 1: GitHub 연동 (권장)

1. **GitHub에 Push**
   ```bash
   git add .
   git commit -m "Prepare for Vercel deployment"
   git push origin main
   ```

2. **Vercel 대시보드에서 Import**
   - [Vercel Dashboard](https://vercel.com/dashboard) 접속
   - "Add New Project" 클릭
   - GitHub 저장소 선택: `BagInCoffee`
   - "Import" 클릭

3. **프로젝트 설정**
   - **Framework Preset**: SvelteKit (자동 감지됨)
   - **Build Command**: `npm run build` (기본값)
   - **Output Directory**: `.vercel/output` (자동)
   - **Install Command**: `npm install` (기본값)

4. **환경 변수 설정**
   - "Environment Variables" 섹션에서 추가:

   | Variable Name | Value | Environment |
   |--------------|-------|-------------|
   | `PUBLIC_SUPABASE_URL` | `https://xxxxx.supabase.co` | Production, Preview, Development |
   | `PUBLIC_SUPABASE_ANON_KEY` | `your-anon-key` | Production, Preview, Development |
   | `R2_ACCOUNT_ID` | `your-account-id` | Production, Preview, Development |
   | `R2_ACCESS_KEY_ID` | `your-access-key` | Production, Preview, Development |
   | `R2_SECRET_ACCESS_KEY` | `your-secret-key` | Production, Preview, Development |
   | `R2_BUCKET_NAME` | `coffeehane` | Production, Preview, Development |
   | `R2_PUBLIC_URL` | `https://pub-xxxxx.r2.dev` | Production, Preview, Development |

5. **Deploy 버튼 클릭**

### 방법 2: Vercel CLI

1. **Vercel CLI 설치**
   ```bash
   npm install -g vercel
   ```

2. **로그인**
   ```bash
   vercel login
   ```

3. **프로젝트 초기화**
   ```bash
   cd C:\project\Remix\BagInCoffee
   vercel
   ```

   질문에 답변:
   - Set up and deploy? `Y`
   - Which scope? (본인 계정 선택)
   - Link to existing project? `N`
   - Project name: `bagincoffee`
   - In which directory? `./`
   - Override settings? `N`

4. **환경 변수 설정**
   ```bash
   vercel env add PUBLIC_SUPABASE_URL production
   vercel env add PUBLIC_SUPABASE_ANON_KEY production
   vercel env add R2_ACCOUNT_ID production
   vercel env add R2_ACCESS_KEY_ID production
   vercel env add R2_SECRET_ACCESS_KEY production
   vercel env add R2_BUCKET_NAME production
   vercel env add R2_PUBLIC_URL production
   ```

5. **배포**
   ```bash
   vercel --prod
   ```

## ⚙️ Vercel 프로젝트 설정

### 1. 리전 설정
현재 설정: `icn1` (Seoul, South Korea)

변경하려면 `svelte.config.js` 수정:
```javascript
adapter: adapter({
    runtime: 'nodejs20.x',
    regions: ['icn1'], // 또는 ['sfo1'], ['iad1'] 등
    maxDuration: 10
})
```

**사용 가능한 리전:**
- `icn1` - Seoul, South Korea (한국)
- `sfo1` - San Francisco, USA (미국 서부)
- `iad1` - Washington, D.C., USA (미국 동부)
- `hnd1` - Tokyo, Japan (일본)
- `sin1` - Singapore (싱가포르)

### 2. 함수 실행 시간 제한
현재 설정: `maxDuration: 10` (10초)

무료 플랜: 최대 10초
Pro 플랜: 최대 60초
Enterprise: 최대 900초

### 3. 빌드 설정
`vercel.json`에서 관리됨:
```json
{
  "buildCommand": "npm run build",
  "framework": "sveltekit",
  "regions": ["icn1"]
}
```

## 🔐 보안 설정

### 1. 환경 변수 암호화
Vercel은 모든 환경 변수를 자동으로 암호화합니다.

### 2. Preview 배포 환경 변수
- Production과 Preview 환경에서 다른 Supabase 프로젝트 사용 권장
- Preview용 별도 환경 변수 설정 가능

### 3. Git Branch 보호
- `main` 브랜치는 Production 배포
- 기타 브랜치는 Preview 배포

## 🎯 배포 후 확인사항

### 1. 기능 테스트
- [ ] 회원가입/로그인
- [ ] 게시물 작성 (이미지 업로드)
- [ ] 댓글 작성/답글
- [ ] 프로필 수정 (아바타 업로드)
- [ ] 관리자 대시보드 (권한 있는 경우)

### 2. 성능 확인
- Vercel Analytics에서 확인
- Lighthouse 점수 확인

### 3. 로그 모니터링
```bash
vercel logs
# 또는 Vercel 대시보드 → 프로젝트 → Logs
```

## 🔄 재배포

### 자동 배포 (GitHub 연동 시)
`main` 브랜치에 push하면 자동 배포됩니다:
```bash
git add .
git commit -m "Update features"
git push origin main
```

### 수동 배포 (CLI)
```bash
vercel --prod
```

### 특정 브랜치 배포
```bash
git checkout feature-branch
git push origin feature-branch
# Vercel이 자동으로 Preview 배포 생성
```

## 🐛 트러블슈팅

### 빌드 실패: "Cannot resolve import"
**원인**: 필요한 패키지가 `package.json`에 없음

**해결**:
```bash
npm install @aws-sdk/client-s3
git add package.json package-lock.json
git commit -m "Add missing dependency"
git push
```

### 환경 변수 오류
**증상**: `undefined` 에러 또는 인증 실패

**해결**:
1. Vercel Dashboard → 프로젝트 → Settings → Environment Variables
2. 모든 변수가 올바르게 설정되었는지 확인
3. 변경 후 재배포 필요

### 이미지 업로드 실패
**원인**: R2 환경 변수 누락 또는 잘못된 값

**확인**:
- `R2_ACCOUNT_ID`가 설정되었는지 확인
- R2 Bucket이 Public Access 허용인지 확인
- CORS 설정 확인

### 함수 실행 시간 초과
**증상**: "Function execution time limit exceeded"

**해결**:
- `svelte.config.js`에서 `maxDuration` 증가
- 또는 Vercel Pro 플랜 업그레이드

## 📊 모니터링

### Vercel Analytics
- 자동으로 활성화됨
- 실시간 트래픽 확인
- Core Web Vitals 측정

### Vercel Logs
```bash
# 실시간 로그 확인
vercel logs --follow

# 특정 시간대 로그
vercel logs --since 1h
```

## 💰 비용

### 무료 플랜 제한
- **대역폭**: 100GB/월
- **빌드 시간**: 100시간/월
- **함수 실행**: 100GB-Hrs
- **함수 실행 시간**: 최대 10초

### 프로젝트 예상 사용량
- 이미지는 R2에 저장 (Vercel 대역폭 절약)
- API 요청은 간단하여 10초 이내 완료
- 일반적인 사용에서는 무료 플랜으로 충분

## 🔗 유용한 링크

- [Vercel Dashboard](https://vercel.com/dashboard)
- [Vercel Docs - SvelteKit](https://vercel.com/docs/frameworks/sveltekit)
- [Vercel Regions](https://vercel.com/docs/edge-network/regions)
- [Environment Variables](https://vercel.com/docs/projects/environment-variables)

## 📝 주의사항

1. **환경 변수는 배포 시 적용됨**
   - 환경 변수 변경 후 재배포 필요
   - Preview와 Production 환경 분리 가능

2. **Custom Domain**
   - Vercel Dashboard에서 도메인 추가 가능
   - 무료 플랜에서도 사용 가능

3. **데이터베이스**
   - Supabase는 별도 호스팅
   - Vercel은 프론트엔드와 API만 호스팅

4. **백업**
   - 정기적으로 Supabase 데이터베이스 백업
   - R2 버킷도 버전 관리 활성화 권장

---

**배포 완료!** 🎉

배포 URL: `https://your-project.vercel.app`

문제가 발생하면 [Vercel Support](https://vercel.com/support)에 문의하세요.
