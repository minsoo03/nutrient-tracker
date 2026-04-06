# API 문서

## 외부 API

| API | URL | 인증 | 용도 |
|-----|-----|------|------|
| 식품안전처 | `various.foodsafetykorea.go.kr/api` | `MFDS_API_KEY` | 한국 식품 6만 개 |
| USDA FoodData | `api.nal.usda.gov/fdc/v1` | `USDA_API_KEY` | 수입식품·보충제 |
| Open Food Facts | `world.openfoodfacts.org/api/v2` | 없음 (무료) | 바코드 조회 |
| OpenAI | `api.openai.com/v1` | `OPENAI_API_KEY` | AI 입력 (Phase 5) |

## 주요 엔드포인트

```
# 식품안전처
GET /foodNtrCpntDbInfo/json?serviceKey={KEY}&FOOD_NM_KR={음식명}

# USDA
GET /foods/search?query={음식명}&api_key={KEY}

# 바코드
GET /product/{barcode}.json

# OpenAI (모델: gpt-4o)
POST /chat/completions
```

## 보안
- 모든 키는 `.env` 저장 — **GitHub 업로드 금지**
- `flutter_dotenv` 패키지로 로드
