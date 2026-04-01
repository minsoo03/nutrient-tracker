# 화면 구성

## 화면 목록
| 화면 | 파일 경로 | 설명 |
|------|-----------|------|
| 스플래시 | `features/auth/splash_screen.dart` | 앱 시작 로딩 |
| 로그인 | `features/auth/login_screen.dart` | 이메일/소셜 로그인 |
| 회원가입 | `features/auth/signup_screen.dart` | 기본 정보 입력 |
| 프로필 설정 | `features/auth/profile_setup_screen.dart` | 신체 정보, 목표 설정 |
| 홈/대시보드 | `features/dashboard/home_screen.dart` | 일일 영양소 현황 |
| 음식 추가 | `features/food_log/add_food_screen.dart` | 음식 검색 & 입력 |
| 음식 검색 | `features/food_log/food_search_screen.dart` | DB 검색 |
| 영양소 상세 | `features/dashboard/nutrient_detail_screen.dart` | 항목별 상세 보기 |
| 장기 건강 탭 | `features/organ_health/organ_health_screen.dart` | 신장·간·카페인 지표 |
| 히스토리 | `features/history/history_screen.dart` | 날짜별 기록 |
| 설정 | `features/settings/settings_screen.dart` | 목표·알림 설정 |

## 대시보드 핵심 컴포넌트
- **칼로리 링**: 목표 대비 섭취 비율 도넛 차트
- **매크로 바**: 탄수화물 / 단백질 / 지방 진행 바
- **경고 카드**: 기준 초과 항목 주황/빨강 뱃지
- **장기 건강 미터**: 신장·간·카페인 신호등 색상 표현

## 네비게이션 구조
```
BottomNavigationBar
  ├── 홈 (대시보드)
  ├── 기록 추가 (+버튼)
  ├── 장기 건강
  ├── 히스토리
  └── 설정
```
