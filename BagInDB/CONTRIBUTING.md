# Contributing to BagInDB

기여에 관심을 가져주셔서 감사합니다! 🎉

## 개발 환경

```bash
# 1. 포크 후 클론
git clone https://github.com/<your-username>/BagInDB.git
cd BagInDB

# 2. 환경변수 설정
cp .env.example .env

# 3. 빌드 & 실행
cargo run
```

## 커밋 컨벤션

```
feat: 새로운 기능
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 리팩토링
test: 테스트 추가/수정
chore: 빌드/설정 변경
```

## Pull Request

1. 이슈 생성
2. 브랜치 생성 (`feat/amazing-feature`)
3. 테스트 실행 (`cargo test`)
4. 린트 확인 (`cargo clippy`)
5. PR 생성

## 코드 스타일

- `cargo fmt` 적용
- `cargo clippy` 경고 없음
