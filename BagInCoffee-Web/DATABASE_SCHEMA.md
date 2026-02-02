# 📊 BagInCoffee Database Schema

커피 소셜 플랫폼의 완전한 데이터베이스 스키마 문서입니다.

## 목차
- [ERD 관계도](#erd-관계도)
- [테이블 상세](#테이블-상세)
- [인덱스 및 성능](#인덱스-및-성능)
- [보안 및 RLS](#보안-및-rls)

---

## ERD 관계도

```
┌─────────────┐
│ auth.users  │ (Supabase Auth)
└──────┬──────┘
       │
       ├─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
       │         │         │         │         │         │         │         │
       ▼         ▼         ▼         ▼         ▼         ▼         ▼         ▼
  ┌─────────┐ ┌────────┐ ┌──────────┐ ┌──────┐ ┌──────────┐ ┌─────────┐ ┌────────┐ ┌──────────────┐
  │profiles │ │ posts  │ │ comments │ │likes │ │equipment_│ │recipes  │ │recipe_ │ │marketplace_  │
  │         │ │        │ │          │ │      │ │ reviews  │ │         │ │ likes  │ │    items     │
  └─────────┘ └───┬────┘ └────┬─────┘ └──┬───┘ └─────┬────┘ └────┬────┘ └────┬───┘ └──────┬───────┘
                  │           │          │           │           │           │            │
                  │           │          │           │           │           │            │
                  └───────────┴──────────┘           │           └───────────┘            │
                                                     │                                    │
                                              ┌──────┴──────┐                      ┌──────┴──────┐
                                              │  equipment  │                      │ equipment   │
                                              │             │                      │(nullable)   │
                                              └──────┬──────┘                      └─────────────┘
                                                     │
                                          ┌──────────┴──────────┐
                                          │ equipment_categories│
                                          └─────────────────────┘

독립 테이블:
┌───────────────┐  ┌────────────────┐
│ coffee_guides │  │ notifications  │
│ (admin only)  │  │                │
└───────────────┘  └────────────────┘
```

---

## 테이블 상세

### 1. profiles - 사용자 프로필
**관계**: auth.users (1:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | - | PK, FK → auth.users | 사용자 고유 ID |
| username | text | YES | - | UNIQUE | 사용자명 (닉네임) |
| full_name | text | YES | - | - | 전체 이름 |
| avatar_url | text | YES | - | - | 프로필 이미지 URL |
| bio | text | YES | - | - | 자기소개 |
| location | text | YES | - | - | 위치 정보 |
| website | text | YES | - | - | 개인 웹사이트 |
| role | text | YES | 'user' | CHECK (role IN ('user', 'admin', 'moderator')) | 사용자 권한 |
| cover_image_url | text | YES | - | - | 커버 이미지 URL |
| avatar_updated_at | timestamptz | YES | now() | - | 아바타 수정 시각 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `UserProfile`, `UserProfileSimple`
**파일**: `src/lib/types/user.ts`

---

### 2. posts - 소셜 피드 게시물
**관계**: auth.users (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 게시물 고유 ID |
| user_id | uuid | NO | - | FK → auth.users | 작성자 ID |
| content | text | NO | - | - | 게시물 내용 |
| likes_count | integer | YES | 0 | - | 좋아요 수 |
| comments_count | integer | YES | 0 | - | 댓글 수 |
| tags | text[] | YES | - | - | 해시태그 배열 |
| images | text[] | YES | '{}' | - | 이미지 URL 배열 (최대 10개) |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `Post`, `PostWithAuthor`, `CreatePostInput`
**파일**: `src/lib/types/Post.ts`

**관련 테이블**:
- likes (1:N) - 좋아요
- comments (1:N) - 댓글

---

### 3. comments - 댓글/대댓글
**관계**: auth.users (N:1), posts (N:1), comments (self-reference)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 댓글 고유 ID |
| user_id | uuid | NO | - | FK → auth.users | 작성자 ID |
| post_id | uuid | NO | - | FK → posts | 게시물 ID |
| content | text | NO | - | - | 댓글 내용 |
| parent_comment_id | uuid | YES | - | FK → comments | 부모 댓글 ID (대댓글용) |
| replies_count | integer | NO | 0 | - | 대댓글 수 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**설명**:
- `parent_comment_id = NULL` → 일반 댓글
- `parent_comment_id != NULL` → 대댓글

**TypeScript 타입**: `Comment`, `CommentWithAuthor`, `CommentTree`
**파일**: `src/lib/types/comment.ts`

---

### 4. likes - 게시물 좋아요
**관계**: auth.users (N:1), posts (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 좋아요 고유 ID |
| user_id | uuid | NO | - | FK → auth.users | 사용자 ID |
| post_id | uuid | NO | - | FK → posts | 게시물 ID |
| created_at | timestamptz | YES | now() | - | 생성 일시 |

**Unique Constraint**: (user_id, post_id) - 중복 좋아요 방지

**TypeScript 타입**: `Like`
**파일**: `src/lib/types/like.ts`

---

### 5. equipment_categories - 장비 카테고리
**관계**: equipment (1:N)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 카테고리 ID |
| name | text | NO | - | UNIQUE | 카테고리명 |
| description | text | YES | - | - | 설명 |
| icon | text | YES | - | - | 아이콘 URL/이름 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |

**현재 데이터**: 8개 카테고리 존재

**TypeScript 타입**: `EquipmentCategory`
**파일**: `src/lib/types/equipment.ts`

---

### 6. equipment - 장비 정보
**관계**: equipment_categories (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 장비 ID |
| category_id | uuid | YES | - | FK → equipment_categories | 카테고리 ID |
| brand | text | NO | - | - | 브랜드명 |
| model | text | NO | - | - | 모델명 |
| description | text | YES | - | - | 설명 |
| image_url | text | YES | - | - | 이미지 URL |
| specs | jsonb | YES | - | - | 사양 (JSONB) |
| price_range | text | YES | - | - | 가격대 (예: "50만원-100만원") |
| rating | numeric | YES | - | - | 평균 평점 |
| reviews_count | integer | YES | 0 | - | 리뷰 수 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `Equipment`, `EquipmentWithCategory`, `EquipmentSpecs`
**파일**: `src/lib/types/equipment.ts`

**관련 테이블**:
- equipment_reviews (1:N) - 리뷰
- marketplace_items (1:N) - 중고 거래 (nullable)

---

### 7. equipment_reviews - 장비 리뷰
**관계**: auth.users (N:1), equipment (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 리뷰 ID |
| user_id | uuid | NO | - | FK → auth.users | 작성자 ID |
| equipment_id | uuid | NO | - | FK → equipment | 장비 ID |
| rating | integer | YES | - | CHECK (rating >= 1 AND rating <= 5) | 평점 (1-5) |
| review | text | YES | - | - | 리뷰 내용 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `EquipmentReview`, `EquipmentReviewWithAuthor`
**파일**: `src/lib/types/equipment.ts`

---

### 8. marketplace_items - 중고 장터
**관계**: auth.users (N:1), equipment (N:1, nullable)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 거래 ID |
| seller_id | uuid | NO | - | FK → auth.users | 판매자 ID |
| equipment_id | uuid | YES | - | FK → equipment | 장비 ID (선택) |
| title | text | NO | - | - | 제목 |
| description | text | YES | - | - | 설명 |
| price | numeric | NO | - | - | 가격 |
| condition | text | YES | - | CHECK (condition IN ('new', 'like_new', 'good', 'fair', 'poor')) | 상태 |
| location | text | YES | - | - | 거래 지역 |
| images | text[] | YES | - | - | 이미지 URL 배열 |
| status | text | YES | 'active' | CHECK (status IN ('active', 'sold', 'reserved')) | 거래 상태 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `MarketplaceItem`, `MarketplaceItemWithSeller`
**파일**: `src/lib/types/marketplace.ts`

---

### 9. recipes - 사용자 레시피
**관계**: auth.users (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 레시피 ID |
| user_id | uuid | NO | - | FK → auth.users | 작성자 ID |
| title | text | NO | - | - | 제목 |
| description | text | YES | - | - | 설명 |
| ingredients | text | YES | '' | - | 재료 |
| instructions | text | YES | - | - | 만드는 방법 |
| brew_method | text | YES | - | CHECK (brew_method IN ('espresso', 'pour_over', 'aeropress', 'french_press', 'moka_pot', 'cold_brew', 'siphon', 'other')) | 추출 방법 |
| brew_time | integer | YES | - | - | 추출 시간 (분) |
| difficulty | text | YES | - | - | 난이도 |
| servings | integer | YES | 1 | - | 인분 |
| tags | text[] | YES | '{}' | - | 태그 배열 |
| likes_count | integer | YES | 0 | - | 좋아요 수 |
| views_count | integer | YES | 0 | - | 조회수 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `Recipe`, `RecipeWithAuthor`, `CreateRecipeInput`
**파일**: `src/lib/types/recipe.ts`

**관련 테이블**:
- recipe_likes (1:N) - 좋아요

---

### 10. recipe_likes - 레시피 좋아요
**관계**: auth.users (N:1), recipes (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 좋아요 ID |
| user_id | uuid | NO | - | FK → auth.users | 사용자 ID |
| recipe_id | uuid | NO | - | FK → recipes | 레시피 ID |
| created_at | timestamptz | YES | now() | - | 생성 일시 |

**Unique Constraint**: (user_id, recipe_id)

---

### 11. coffee_guides - 커피 가이드 (어드민 전용)
**관계**: 없음 (독립 테이블)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | gen_random_uuid() | PK | 가이드 ID |
| title | text | NO | - | - | 제목 |
| slug | text | NO | - | UNIQUE | URL용 고유 식별자 |
| content | text | NO | - | - | 내용 (Markdown) |
| excerpt | text | YES | - | - | 요약 |
| category | text | NO | - | CHECK (category IN ('brewing', 'beans', 'equipment', 'recipe', 'roasting', 'barista', 'science', 'culture', 'other')) | 카테고리 |
| tags | text[] | YES | '{}' | - | 태그 배열 |
| cover_image | text | YES | - | - | 커버 이미지 |
| published | boolean | YES | false | - | 발행 여부 |
| featured | boolean | YES | false | - | 추천 여부 |
| views_count | integer | YES | 0 | - | 조회수 |
| reading_time_minutes | integer | YES | - | - | 예상 읽기 시간 (분) |
| difficulty | text | YES | - | CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')) | 난이도 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |
| published_at | timestamptz | YES | - | - | 발행 일시 |

**TypeScript 타입**: `CoffeeGuide`, `GuideCategory`
**파일**: `src/lib/types/content.ts`

---

### 12. news_articles - 커피 뉴스
**관계**: auth.users (N:1, nullable)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | uuid_generate_v4() | PK | 뉴스 ID |
| author_id | uuid | YES | - | FK → auth.users | 작성자 ID (nullable) |
| title | text | NO | - | - | 제목 |
| content | text | NO | - | - | 내용 |
| excerpt | text | YES | - | - | 요약 |
| cover_image | text | YES | - | - | 커버 이미지 |
| tags | text[] | YES | - | - | 태그 배열 |
| published | boolean | YES | false | - | 발행 여부 |
| views_count | integer | YES | 0 | - | 조회수 |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| updated_at | timestamptz | YES | now() | - | 수정 일시 |

**TypeScript 타입**: `NewsArticle`
**파일**: `src/lib/types/content.ts`

---

### 13. notifications - 알림
**관계**: auth.users (N:1)

| 컬럼명 | 타입 | NULL | 기본값 | 제약조건 | 설명 |
|--------|------|------|--------|----------|------|
| id | uuid | NO | gen_random_uuid() | PK | 알림 ID |
| user_id | uuid | NO | - | FK → auth.users | 수신자 ID |
| type | text | NO | - | CHECK (type IN ('like', 'comment', 'follow', 'mention', 'system')) | 알림 타입 |
| title | text | NO | - | - | 제목 |
| message | text | NO | - | - | 메시지 |
| link | text | YES | - | - | 링크 URL |
| is_read | boolean | YES | false | - | 읽음 여부 |
| data | jsonb | YES | - | - | 추가 데이터 (JSONB) |
| created_at | timestamptz | YES | now() | - | 생성 일시 |
| read_at | timestamptz | YES | - | - | 읽은 일시 |

**TypeScript 타입**: `Notification`, `NotificationType`
**파일**: `src/lib/types/notification.ts`

---

## 인덱스 및 성능

### 권장 인덱스

```sql
-- posts 테이블
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);

-- comments 테이블
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_comment_id) WHERE parent_comment_id IS NOT NULL;

-- likes 테이블
CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_user_post ON likes(user_id, post_id);

-- notifications 테이블
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC);

-- equipment 테이블
CREATE INDEX idx_equipment_category ON equipment(category_id);

-- marketplace_items 테이블
CREATE INDEX idx_marketplace_status ON marketplace_items(status) WHERE status = 'active';
```

---

## 보안 및 RLS

### Row Level Security (RLS)

**활성화된 테이블**:
- ✅ profiles
- ✅ posts
- ✅ comments
- ✅ likes
- ✅ equipment_reviews
- ✅ recipes
- ✅ recipe_likes
- ✅ marketplace_items
- ✅ notifications

### RLS 정책 예시

```sql
-- posts: 모든 사용자가 읽을 수 있음
CREATE POLICY "Posts are publicly readable"
  ON posts FOR SELECT
  USING (true);

-- posts: 본인만 생성 가능
CREATE POLICY "Users can create their own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- posts: 본인만 수정/삭제 가능
CREATE POLICY "Users can update their own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own posts"
  ON posts FOR DELETE
  USING (auth.uid() = user_id);
```

---

## TypeScript 타입 매핑

| 테이블 | TypeScript 파일 | 주요 타입 |
|--------|----------------|-----------|
| profiles | `types/user.ts` | `UserProfile`, `UserProfileSimple` |
| posts | `types/Post.ts` | `Post`, `PostWithAuthor` |
| comments | `types/comment.ts` | `Comment`, `CommentWithAuthor` |
| likes | `types/like.ts` | `Like` |
| equipment | `types/equipment.ts` | `Equipment`, `EquipmentWithCategory` |
| equipment_reviews | `types/equipment.ts` | `EquipmentReview` |
| marketplace_items | `types/marketplace.ts` | `MarketplaceItem` |
| recipes | `types/recipe.ts` | `Recipe`, `RecipeWithAuthor` |
| coffee_guides | `types/content.ts` | `CoffeeGuide` |
| news_articles | `types/content.ts` | `NewsArticle` |
| notifications | `types/notification.ts` | `Notification` |

---

## 데이터베이스 통계

- **총 테이블 수**: 13개
- **인증 관련**: 1개 (auth.users - Supabase)
- **사용자 콘텐츠**: 6개 (profiles, posts, comments, recipes, marketplace_items, equipment_reviews)
- **장비 관련**: 3개 (equipment_categories, equipment, equipment_reviews)
- **시스템**: 3개 (coffee_guides, news_articles, notifications)
- **관계 테이블**: 2개 (likes, recipe_likes)

---

## 업데이트 이력

- **2025-01-XX**: 초기 스키마 생성
- **2025-01-XX**: equipment 테이블에 specs (jsonb) 추가
- **2025-01-XX**: profiles에 cover_image_url, avatar_updated_at 추가
- **2025-01-XX**: 모든 타입 정의 DB 스키마와 완전 일치 확인 완료

---

## 참고사항

- 모든 timestamptz 필드는 UTC 기준입니다
- uuid는 `uuid_generate_v4()` 또는 `gen_random_uuid()` 사용
- JSONB 필드는 유연한 데이터 구조를 위해 사용 (specs, data)
- RLS는 모든 주요 테이블에 적용되어 있습니다
- 외래 키는 ON DELETE CASCADE 또는 ON DELETE SET NULL 정책 적용

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-01-XX
**관리자**: BagInCoffee Team
