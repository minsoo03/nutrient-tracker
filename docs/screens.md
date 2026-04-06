# 화면 구성

## 화면 목록
| 화면 | 파일 | 설명 |
|------|------|------|
| 스플래시 | `auth/splash_screen.dart` | 로딩 |
| 로그인 | `auth/login_screen.dart` | 이메일 로그인 |
| 회원가입 | `auth/signup_screen.dart` | 계정 생성 |
| 프로필 설정 | `auth/profile_setup_screen.dart` | 신체정보·목표 |
| 홈 | `dashboard/home_screen.dart` | 일일 영양소 현황 |
| 음식 추가 | `food_log/add_food_screen.dart` | 검색·입력 |
| 영양소 상세 | `dashboard/nutrient_detail_screen.dart` | 항목별 상세 |
| 장기 건강 | `organ_health/organ_health_screen.dart` | 신장·간·카페인 |
| 히스토리 | `history/history_screen.dart` | 날짜별 기록 |
| 설정 | `settings/settings_screen.dart` | 목표·알림 |

## 네비게이션
```
BottomNav: 홈 / + (추가) / 장기건강 / 히스토리 / 설정
```

## 대시보드 컴포넌트
| 컴포넌트 | 설명 |
|----------|------|
| 칼로리 링 | 목표 대비 섭취 도넛 차트 |
| 매크로 바 | 탄수화물·단백질·지방 진행 바 |
| 경고 카드 | 초과 항목 주황/빨강 뱃지 |
| 장기 건강 미터 | 신장·간·카페인 신호등 색상 |
