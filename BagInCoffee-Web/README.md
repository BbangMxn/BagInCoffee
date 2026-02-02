<!-- PROJECT SHIELDS -->
<div align="center">

[![SvelteKit][sveltekit-shield]][sveltekit-url]
[![TypeScript][ts-shield]][ts-url]
[![Supabase][supabase-shield]][supabase-url]
[![License][license-shield]][license-url]

</div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/BbangMxn/BagInCoffee-Web">
    <img src="docs/logo.png" alt="Logo" width="100" height="100">
  </a>

  <h3 align="center">BagInCoffee Web</h3>

  <p align="center">
    커피 애호가를 위한 소셜 커뮤니티 플랫폼
    <br />
    <a href="#-api"><strong>API 문서 »</strong></a>
    <br />
    <br />
    <a href="#-빠른-시작">빠른 시작</a>
    ·
    <a href="https://github.com/BbangMxn/BagInCoffee-Web/issues">버그 리포트</a>
    ·
    <a href="https://github.com/BbangMxn/BagInCoffee-Web/issues">기능 제안</a>
  </p>
</div>

<!-- ABOUT -->
## 프로젝트 소개

<img src="docs/screenshot.png" alt="Screenshot" width="600">

**BagInCoffee**는 커피 애호가들이 경험을 공유하고 소통하는 소셜 플랫폼입니다.

- 📱 **소셜 피드** — 게시물, 좋아요, 실시간 알림
- 💬 **중첩 댓글** — 2단계 계층 구조, 댓글 좋아요
- 🛒 **중고 거래** — 장비 마켓플레이스
- 📚 **매거진** — 커피 가이드, 에디터 큐레이션

### 기술 스택

[![SvelteKit][sveltekit-badge]][sveltekit-url]
[![TypeScript][ts-badge]][ts-url]
[![Tailwind][tailwind-badge]][tailwind-url]
[![Supabase][supabase-badge]][supabase-url]

<!-- GETTING STARTED -->
## 🚀 빠른 시작

```bash
# 1. 클론
git clone https://github.com/BbangMxn/BagInCoffee-Web.git
cd BagInCoffee

# 2. 의존성 설치
npm install

# 3. 환경변수
cp .env.example .env

# 4. 실행
npm run dev
```

### 환경변수

```env
PUBLIC_SUPABASE_URL="https://xxx.supabase.co"
PUBLIC_SUPABASE_ANON_KEY="your-anon-key"
R2_ACCOUNT_ID="your-account-id"
R2_ACCESS_KEY_ID="your-access-key"
```

<!-- PROJECT STRUCTURE -->
## 📂 프로젝트 구조

```
src/
├── lib/
│   ├── components/     # Svelte 컴포넌트
│   ├── server/
│   │   └── database/Repository/  # 데이터 접근
│   └── types/          # TypeScript 타입
└── routes/
    ├── api/            # API 엔드포인트
    ├── posts/[id]/     # 게시물 상세
    └── magazine/       # 매거진
```

<!-- SCRIPTS -->
## 📜 스크립트

```bash
npm run dev      # 개발 서버
npm run build    # 프로덕션 빌드
npm run preview  # 빌드 프리뷰
npm run check    # 타입 체크
```

<!-- ROADMAP -->
## 🗺️ 로드맵

- [x] 소셜 피드
- [x] 중첩 댓글
- [x] 중고 거래
- [x] 매거진
- [ ] 실시간 채팅
- [ ] 추천 알고리즘

<!-- LICENSE -->
## 📄 라이선스

MIT License - [LICENSE](LICENSE)

---

<div align="center">
  
**[⬆ 맨 위로](#bagincoffee-web)**

</div>

<!-- MARKDOWN LINKS -->
[sveltekit-shield]: https://img.shields.io/badge/SvelteKit-FF3E00?style=for-the-badge&logo=svelte&logoColor=white
[sveltekit-url]: https://kit.svelte.dev/
[ts-shield]: https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white
[ts-url]: https://www.typescriptlang.org/
[supabase-shield]: https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white
[supabase-url]: https://supabase.com/
[license-shield]: https://img.shields.io/badge/License-MIT-blue?style=for-the-badge
[license-url]: LICENSE

[sveltekit-badge]: https://img.shields.io/badge/SvelteKit-FF3E00?style=for-the-badge&logo=svelte&logoColor=white
[ts-badge]: https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white
[tailwind-badge]: https://img.shields.io/badge/Tailwind-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white
[tailwind-url]: https://tailwindcss.com/
[supabase-badge]: https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white
