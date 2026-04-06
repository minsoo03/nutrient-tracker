# 개발 규칙

## 코드
- 파일당 최대 **200줄** — 초과 시 즉시 파일 분리

## Git
- 수정마다 **commit & push** 필수
- 커밋 prefix: `feat:` `fix:` `refactor:` `docs:`

## 문서
- 주제별 파일 분리 (`rules` `overview` `api` `database` `screens`)
- 서술형 문장 금지 — 헤딩·리스트·테이블만

## 폴더 구조
```
lib/
  core/        # 테마, 라우터, 상수
  features/    # auth / dashboard / food_log / organ_health
  models/
  services/    # Firebase, 외부 API
```
