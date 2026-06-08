# Nutrient Tracker

일일 영양소 · 장기 건강 · 약물 위험 통합 트래커 (Flutter + Supabase/PostgreSQL)

2026년 1학기 데이터베이스 프로젝트 — 강민수 (202220791)

## 핵심 기술

- **Frontend**: Flutter 3.x (Dart) + go_router + supabase_flutter
- **Backend / DBMS**: Supabase (PostgreSQL 15)
- **데이터 소스**:
  - 공공데이터포털 (data.go.kr) + 식약처 식품영양성분DB
  - USDA FoodData Central
  - LLM(Claude) 생성 카탈로그 (약물 30종, 운동 31종) + 데모 시드

## 빌드 및 실행

### 1. 사전 준비

```bash
# Flutter SDK 3.11+ 설치 후
flutter --version  # Dart 3.11+ 확인
```

### 2. 환경 변수 설정

```bash
cp .env.example .env
# .env 파일을 열어 본인의 Supabase URL/key + 공공데이터 API 키 입력
```

### 3. Supabase 스키마 생성

Supabase 프로젝트 만든 뒤 SQL Editor에서 순서대로 실행:

```bash
supabase/schema.sql        # 테이블·트리거·뷰·인덱스·RLS·LLM 카탈로그 시드
supabase/demo_seed.sql     # 가상 사용자 5명 + 일주일치 데모 데이터
supabase/report_queries.sql  # 보고서용 SQL 예시 (선택)
```

### 4. 앱 실행

```bash
flutter pub get
flutter run
```

## 디렉터리 구조

```
lib/
  core/                       # 테마·라우터·상수·공용 위젯
  features/
    auth/                     # 회원가입·로그인·프로필 설정
    dashboard/                # 홈·음식 추가·운동·약물·히스토리
  models/                     # Dart 데이터 모델
  services/                   # Supabase / 외부 API 호출 서비스
  data/                       # 음식·약물 보조 카탈로그
  utils/                      # 헬퍼

supabase/                     # PostgreSQL 스키마 + 시드 + 보고서 쿼리
docs/                         # 기획 문서
```

## 가산점 구현 (보고서 [4] SQL 항목)

- **Trigger**: `fn_rebuild_daily_log()` — food/exercise 변경 시 daily_logs 자동 합산
- **View**: `v_weekly_nutrition_summary` — 주간 영양 요약
- **Rollup OLAP**: `report_queries.sql` Q6 — 월·주·일 다단 집계

## 보안 메모

- `.env`는 절대 git에 올리지 않음 (`.gitignore` 등록)
- 모든 사용자 테이블은 Row Level Security (RLS) 적용 — `auth.uid() = user_id`
- 공유 카탈로그(`branded_foods`, `medication_catalog`, `exercise_catalog`)는 read-only public

## 참고 문서

| 파일 | 내용 |
|------|------|
| `docs/overview.md` | 앱 개요 & 로드맵 |
| `docs/rules.md` | 개발 규칙 |
| `docs/database.md` | DB 스키마 설명 |
| `docs/api.md` | 외부 API |
| `docs/screens.md` | 화면 구성 |
