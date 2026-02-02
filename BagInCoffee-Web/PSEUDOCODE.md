# BagInCoffee - 기술 상세 & 의사코드

> 핵심 기능의 구현 로직 및 의사코드

## 1. 인증 시스템

### 회원가입
```
signup(email, password, profile):
  1. 입력 검증 (필수값, 비밀번호 길이)
  2. 아바타 이미지 업로드 (R2)
  3. Supabase Auth 계정 생성
  4. profiles 테이블에 프로필 저장
  5. 세션 생성 및 자동 로그인
```

### 로그인
```
login(email, password):
  1. 입력 검증
  2. Supabase Auth 로그인
  3. 프로필 데이터 조회 (profiles 테이블)
  4. 세션 쿠키 저장
  5. 홈으로 리다이렉트
```

## 2. 게시물 시스템

### 게시물 작성
```
createPost(content, images[], userId):
  1. 입력 검증 (내용 또는 이미지 필수, 최대 5장)
  2. 각 이미지 검증:
     - 파일 크기 (5MB 이하)
     - MIME 타입 (jpeg, png, gif, webp)
     - 파일 확장자
     - Magic Number (실제 파일 내용 확인)
  3. R2에 이미지 업로드:
     - UUID 기반 고유 파일명 생성
     - Cloudflare R2 업로드
     - Public URL 획득
  4. DB에 게시물 저장:
     - content, images[], likes_count=0, comments_count=0
  5. 실패시 Rollback: 업로드된 이미지 삭제
  6. 성공시 게시물 상세 페이지로 이동
```

### 게시물 목록
```
getPosts(page, limit, userId):
  1. offset 계산
  2. JOIN 쿼리로 최적화:
     - posts + profiles (작성자 정보)
     - has_liked (현재 사용자의 좋아요 여부)
  3. 페이지네이션 (최신순)
  4. has_more 플래그 계산
```

## 3. 댓글 시스템

### 댓글 작성 (2단계 중첩)
```
createComment(postId, content, parentId, userId):
  1. 입력 검증 (500자 이하)
  2. 게시물 존재 확인
  3. 대댓글인 경우:
     - 부모 댓글 존재 확인
     - 부모의 parent_id 확인 (null이어야 함)
     - 2단계 이상 중첩 방지
  4. 트랜잭션:
     - comments 테이블에 INSERT
     - posts.comments_count++ (UPDATE)
     - COMMIT
  5. 실패시 ROLLBACK
```

### 댓글 계층 구조 조회
```
getCommentsWithReplies(postId, userId):
  1. 모든 댓글 조회 (parent_id NULLS FIRST 정렬)
  2. Map 자료구조로 변환
  3. 부모-자식 관계 연결:
     - parent_id가 null이면 root_comments에 추가
     - parent_id가 있으면 parent.replies에 추가
  4. root_comments 반환 (중첩 구조)
```

### 댓글 삭제
```
deleteComment(commentId, userId):
  1. 권한 확인 (user_id 일치)
  2. 대댓글 개수 확인:
     - 있으면: Soft Delete (content = "삭제된 댓글", is_deleted = true)
     - 없으면: Hard Delete (완전 삭제 + comments_count--)
  3. 트랜잭션으로 처리
```

## 4. 이미지 업로드 & 검증

### Magic Number 파일 검증
```
validateImageFile(file):
  1. 파일 크기 확인 (5MB 이하)
  2. MIME 타입 확인 (화이트리스트)
  3. 파일 확장자 확인 (화이트리스트)
  4. Magic Number 검증:
     JPEG: FF D8 FF (E0/E1/E2/E3/E8)
     PNG:  89 50 4E 47 0D 0A 1A 0A
     GIF:  47 49 46 38 (37 61 / 39 61)
     WebP: 52 49 46 46 [4 bytes] 57 45 42 50
  5. 확장자와 실제 파일 형식 일치 확인
  6. 불일치시 에러 반환
```

### R2 업로드
```
uploadToR2(file, folder, filename):
  1. UUID 기반 고유 파일명 생성
  2. File을 ArrayBuffer로 변환
  3. S3 Client로 PutObjectCommand 실행
  4. Public URL 반환: ${R2_PUBLIC_URL}/${unique_filename}
```

## 5. 좋아요 시스템

### 좋아요 토글 (게시물/댓글)
```
toggleLike(targetId, userId, type):
  BEGIN TRANSACTION:
    1. 기존 좋아요 확인 (SELECT)
    2. 있으면:
       - DELETE FROM {type}_likes
       - UPDATE {type}s SET likes_count--
       - action = "unliked"
    3. 없으면:
       - INSERT INTO {type}_likes
       - UPDATE {type}s SET likes_count++
       - action = "liked"
    4. COMMIT
  5. 업데이트된 likes_count와 has_liked 반환
  6. 실패시 ROLLBACK
```

## 6. 프로필 관리

### 프로필 수정
```
updateProfile(userId, profileData, avatar):
  1. 사용자명 중복 확인
  2. 아바타 변경시:
     - 파일 검증 (Magic Number, 2MB 이하)
     - R2 업로드
     - 기존 아바타 삭제
  3. 트랜잭션:
     - profiles 테이블 UPDATE
     - updated_at = NOW()
  4. 실패시 Rollback (새 이미지 삭제)
```

## 7. 데이터 플로우

### 게시물 작성 플로우
```
User Input → 입력 검증 → 각 이미지 검증 (Magic Number) 
→ R2 업로드 → DB 저장 → 성공 응답 / Rollback
```

### 댓글 작성 플로우 (중첩)
```
User Input → 검증 → 게시물 확인 → 부모 댓글 확인 (2단계 제한)
→ Transaction (INSERT comment + UPDATE post) → 사용자 정보 조인 → UI 업데이트
```

### 좋아요 플로우
```
Click → 기존 좋아요 확인 → Transaction (INSERT/DELETE + UPDATE count)
→ 업데이트된 count 조회 → UI 반영
```

## 8. 성능 최적화

### N+1 쿼리 방지
```sql
-- ❌ Bad
SELECT * FROM posts;  -- N번의 추가 쿼리 발생
FOR EACH post: SELECT * FROM profiles WHERE id = post.user_id;

-- ✅ Good
SELECT p.*, profiles.username, profiles.avatar_url
FROM posts p
LEFT JOIN profiles ON p.user_id = profiles.id;
```

### 이미지 Lazy Loading
```html
<img src={url} loading="lazy" decoding="async" />
```

### 프로필 캐싱
```
캐시 키: profile:{userId}
TTL: 5분
캐시 히트 → 즉시 반환
캐시 미스 → DB 조회 → 캐시 저장 → 반환
```

## 9. 보안 체크리스트

### 입력 검증
- [x] Content Length 제한
- [x] File Size 제한 (아바타 2MB, 게시물 5MB)
- [x] File Type 화이트리스트
- [x] Magic Number 검증
- [x] SQL Injection 방지 (Parameterized Query)
- [x] XSS 방지 (Content Sanitization)

### 인증/인가
- [x] JWT Token 검증 (Supabase Auth)
- [x] Row Level Security (RLS)
- [x] Rate Limiting (계획중)

### 데이터 보호
- [x] Password Hashing (Supabase 내장)
- [x] HTTPS Only (Vercel 기본)
- [x] Secure Cookie (httpOnly, secure, sameSite)

### 파일 업로드
- [x] Magic Number 검증
- [x] Size 제한
- [x] UUID 기반 Unique Filename
- [x] Separate Domain (R2 Public URL)

## 10. API 응답 형식

### Success
```json
{
  "success": true,
  "data": { /* 실제 데이터 */ },
  "message": "작업이 완료되었습니다"
}
```

### Error
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력값이 올바르지 않습니다",
    "details": {
      "field": "email",
      "reason": "이메일 형식이 아닙니다"
    }
  }
}
```

---

## 주요 기술 결정

| 항목 | 선택 | 이유 |
|------|------|------|
| Frontend | SvelteKit (Svelte 5) | 작은 번들, 명확한 반응성, TypeScript 지원 |
| Database | Supabase (PostgreSQL) | RLS, Real-time, Auth 내장 |
| Storage | Cloudflare R2 | S3 호환, 무료 egress, 빠른 CDN |
| Deployment | Vercel | SvelteKit 최적화, Seoul Region |
| 반응성 | `$state()` Runes | Svelte 5 새로운 시스템 |
| 환경 변수 | `$env/dynamic/private` | Vercel 런타임 주입 |

---

_관련 문서: [DEPLOYMENT.md](DEPLOYMENT.md) | [SECURITY.md](SECURITY.md) | [README.md](README.md)_
