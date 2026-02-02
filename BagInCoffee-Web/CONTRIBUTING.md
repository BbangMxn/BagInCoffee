# Contributing to BagInCoffee Web

기여에 관심을 가져주셔서 감사합니다! 🎉

## 개발 환경

```bash
# 1. 포크 후 클론
git clone https://github.com/<your-username>/BagInCoffee.git
cd BagInCoffee

# 2. 의존성 설치
npm install

# 3. 환경변수 설정
cp .env.example .env

# 4. 개발 서버 실행
npm run dev
```

## 커밋 컨벤션

```
feat: 새로운 기능
fix: 버그 수정
docs: 문서 수정
style: 스타일 변경 (CSS)
refactor: 리팩토링
test: 테스트 추가/수정
chore: 빌드/설정 변경
```

## Pull Request

1. 이슈 생성
2. 브랜치 생성 (`feat/amazing-feature`)
3. 타입 체크 (`npm run check`)
4. 린트 확인 (`npm run lint`)
5. PR 생성

## 코드 스타일

- ESLint + Prettier
- Svelte 5 Runes 사용
- TypeScript strict mode
