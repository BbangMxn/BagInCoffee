# 보안 업데이트 가이드

## ✅ Supabase Auth 보안 강화 완료!

### 문제점 (해결됨)
Supabase에서 `auth.getSession()`을 직접 사용하면 보안 경고가 발생했습니다:

```
⚠️ Using the user object as returned from supabase.auth.getSession()
or from some supabase.auth.onAuthStateChange() events could be insecure!
This value comes directly from the storage medium (usually cookies on the server)
and may not be authentic. Use supabase.auth.getUser() instead which authenticates
the data by contacting the Supabase Auth server.
```

### 왜 위험했나?
- ❌ `auth.getSession()`은 쿠키에서 세션 정보를 **직접** 읽음
- ❌ 악의적인 사용자가 쿠키를 조작 가능
- ❌ 서버에서 실제로 유효한 세션인지 검증하지 않음

### ✅ 해결 방법 (적용 완료)

#### 1. `hooks.server.ts` 완전 재작성 ✅

**이전 코드 (위험):**
```typescript
// ❌ 직접 getSession() 호출 - 보안 경고 발생!
event.locals.getSession = async () => {
  const { data: { session } } = await event.locals.supabase.auth.getSession();
  return session;
};
```

**현재 코드 (안전):**
```typescript
// ✅ getUser()로 먼저 검증 - 경고 없음!
event.locals.getSession = async () => {
  // 1. 서버에 사용자 검증 (보안 권장사항)
  const { data: { user } } = await event.locals.supabase.auth.getUser();

  if (!user) {
    return null;
  }

  // 2. 검증 후 세션 반환
  const { data: { session } } = await event.locals.supabase.auth.getSession();
  return session;
};

// ✅ 민감한 작업용 추가 보안
event.locals.safeGetSession = async () => {
  const { data: { user }, error } = await event.locals.supabase.auth.getUser();

  if (error || !user) {
    return { session: null, user: null };
  }

  const { data: { session } } = await event.locals.supabase.auth.getSession();
  return { session, user };
};
```

**핵심 변경사항:**
- 🔒 **모든** `getSession()` 호출 전에 `getUser()`로 검증
- 🔒 민감한 작업에는 `safeGetSession()` 사용
- ✅ Supabase 보안 경고 **완전 제거**

#### 2. 사용 가이드라인

**✅ `getSession()` 사용해도 되는 경우:**
- 단순 UI 표시 (로그인 상태 확인)
- 읽기 전용 데이터 조회
- 민감하지 않은 정보

**⚠️ `safeGetSession()` 필수 사용:**
- 파일 업로드
- 데이터 생성/수정/삭제
- 결제 처리
- 권한이 필요한 작업
- 개인정보 수정

#### 3. 적용된 파일 목록

✅ **업로드 API (필수)**
- `/api/upload/post-images/+server.ts`
- `/api/upload/avatar/+server.ts`

✅ **게시물 생성**
- `/api/posts/+server.ts` (POST)

✅ **프로필 수정**
- `/profile/edit/+page.server.ts` (actions)

⚪ **유지 (getSession)**
- `/+layout.server.ts` - 레이아웃 로드 (읽기만)
- `/api/posts/+server.ts` (GET) - 피드 조회
- 기타 읽기 전용 페이지

### 마이그레이션 예시

**Before:**
```typescript
export const POST: RequestHandler = async ({ request, locals: { getSession } }) => {
  const session = await getSession();

  if (!session?.user) {
    return error(401, 'Unauthorized');
  }

  const userId = session.user.id;
  // ...
};
```

**After:**
```typescript
export const POST: RequestHandler = async ({ request, locals: { safeGetSession } }) => {
  const { session, user } = await safeGetSession();

  if (!session || !user) {
    return error(401, 'Unauthorized');
  }

  const userId = user.id;
  // ...
};
```

### 성능 영향

- `safeGetSession()`은 Supabase Auth 서버에 추가 요청을 보냅니다
- 일반적으로 50-200ms 추가 지연
- 하지만 **보안이 성능보다 중요**합니다
- 민감한 작업에만 사용하여 균형 유지

### 체크리스트

- [x] hooks.server.ts에 safeGetSession 추가
- [x] app.d.ts에 타입 정의 추가
- [x] 파일 업로드 API 수정
- [x] 게시물 생성 API 수정
- [x] 프로필 수정 action 수정
- [ ] 결제 API 추가 시 safeGetSession 사용
- [ ] 관리자 작업에 safeGetSession 적용

### 추가 보안 권장사항

1. **Rate Limiting**: API 호출 제한
2. **CSRF Protection**: SvelteKit 자동 제공
3. **Input Validation**: 모든 사용자 입력 검증
4. **File Upload Security**:
   - MIME type 검증
   - File size 제한
   - Magic number 체크 (이미 적용됨)

## 관련 문서

- [Supabase Auth Best Practices](https://supabase.com/docs/guides/auth/server-side/nextjs)
- [SvelteKit Security](https://kit.svelte.dev/docs/security)
