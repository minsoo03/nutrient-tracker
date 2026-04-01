# 개발 규칙 (절대 엄수)

## 1. 코드 줄 수 제한
- 파일 하나당 **최대 200줄**
- 200줄 초과 시 **즉시 리팩토링** (파일 분리 또는 함수 정리)

## 2. Git Push 규칙
- 파일 수정할 때마다 **반드시 git commit & push**
- 커밋 메시지는 변경 내용을 명확하게 작성
  ```
  feat: 로그인 화면 UI 추가
  fix: 영양소 계산 버그 수정
  refactor: nutrition_service 파일 분리
  docs: API 문서 업데이트
  ```

## 3. 문서 분리 규칙
- 개발 규칙 → `docs/rules.md` (이 파일)
- 앱 개요 → `docs/overview.md`
- API 문서 → `docs/api.md`
- DB 스키마 → `docs/database.md`
- 화면 구성 → `docs/screens.md`
- 모든 문서는 주제별로 **반드시 별도 파일**로 관리

## 4. 폴더 구조 규칙
```
lib/
  features/         # 기능별 폴더 분리
    auth/
    dashboard/
    food_log/
    organ_health/
  core/             # 공통 유틸, 상수, 테마
  models/           # 데이터 모델
  services/         # Firebase, API 연동
```
