<!-- PROJECT SHIELDS -->
<div align="center">

[![Flutter][flutter-shield]][flutter-url]
[![Dart][dart-shield]][dart-url]
[![Supabase][supabase-shield]][supabase-url]
[![License][license-shield]][license-url]

</div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/BbangMxn/BagInCoffee-App">
    <img src="docs/logo.png" alt="Logo" width="100" height="100">
  </a>

  <h3 align="center">BagInCoffee App</h3>

  <p align="center">
    커피 애호가를 위한 소셜 플랫폼 모바일 앱
    <br />
    <a href="#-아키텍처"><strong>아키텍처 »</strong></a>
    <br />
    <br />
    <a href="#-빠른-시작">빠른 시작</a>
    ·
    <a href="https://github.com/BbangMxn/BagInCoffee-App/issues">버그 리포트</a>
    ·
    <a href="https://github.com/BbangMxn/BagInCoffee-App/issues">기능 제안</a>
  </p>
</div>

<!-- ABOUT -->
## 프로젝트 소개

<img src="docs/screenshot.png" alt="Screenshot" width="600">

**BagInCoffee App**은 Flutter 기반 크로스 플랫폼 모바일 앱입니다.

- 📱 **크로스 플랫폼** — iOS & Android 동시 지원
- 🔔 **푸시 알림** — 댓글, 좋아요, 팔로워 알림
- ☕ **추출 기록** — 레시피 저장, 원두별 기록
- 📚 **가이드** — 커피 가이드, 장비 리뷰

### 기술 스택

[![Flutter][flutter-badge]][flutter-url]
[![Dart][dart-badge]][dart-url]
[![Riverpod][riverpod-badge]][riverpod-url]
[![Supabase][supabase-badge]][supabase-url]

<!-- ARCHITECTURE -->
## 🏗️ 아키텍처

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│    Widgets · Screens · Providers        │
├─────────────────────────────────────────┤
│         Riverpod State Manager          │
├─────────────────────────────────────────┤
│            Services (API, Auth)         │
├─────────────────────────────────────────┤
│   Supabase  │  Main API  │  BagInDB    │
└─────────────────────────────────────────┘
```

<!-- GETTING STARTED -->
## 🚀 빠른 시작

```bash
# 1. Flutter 확인
flutter doctor

# 2. 클론
git clone https://github.com/BbangMxn/BagInCoffee-App.git
cd BagInCoffee_Flutter

# 3. 의존성 설치
flutter pub get

# 4. 실행
flutter run
```

<!-- PROJECT STRUCTURE -->
## 📂 프로젝트 구조

```
lib/
├── core/           # 상수, 테마, 네트워크
├── features/       # 기능별 모듈
│   ├── auth/       # 로그인, 회원가입
│   ├── home/       # 홈 피드
│   ├── post/       # 게시물
│   └── profile/    # 프로필
└── shared/         # 공통 모델, 위젯
```

<!-- BUILD -->
## 📱 빌드

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

<!-- ROADMAP -->
## 🗺️ 로드맵

- [x] 인증 시스템
- [x] 홈 피드
- [x] 푸시 알림
- [ ] 오프라인 모드
- [ ] 다크 모드

<!-- LICENSE -->
## 📄 라이선스

MIT License - [LICENSE](LICENSE)

---

<div align="center">
  
**[⬆ 맨 위로](#bagincoffee-app)**

</div>

<!-- MARKDOWN LINKS -->
[flutter-shield]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[flutter-url]: https://flutter.dev/
[dart-shield]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[dart-url]: https://dart.dev/
[supabase-shield]: https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white
[supabase-url]: https://supabase.com/
[license-shield]: https://img.shields.io/badge/License-MIT-blue?style=for-the-badge
[license-url]: LICENSE

[flutter-badge]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[dart-badge]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[riverpod-badge]: https://img.shields.io/badge/Riverpod-00D1B2?style=for-the-badge
[riverpod-url]: https://riverpod.dev/
[supabase-badge]: https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white
