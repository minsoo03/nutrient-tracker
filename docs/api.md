# API 문서

## 외부 API 목록

### 1. 식품안전처 식품영양성분 DB
- **URL:** https://various.foodsafetykorea.go.kr/api
- **인증:** API 키 필요 (환경변수 `MFDS_API_KEY`)
- **용도:** 한국 식품 6만여 개 영양소 데이터
- **주요 엔드포인트:**
  ```
  GET /foodNtrCpntDbInfo/json
    ?serviceKey={API_KEY}
    &FOOD_NM_KR={음식명}
    &startIdx=1&endIdx=10
  ```

### 2. USDA FoodData Central
- **URL:** https://api.nal.usda.gov/fdc/v1
- **인증:** API 키 필요 (환경변수 `USDA_API_KEY`)
- **용도:** 수입 식품, 보충제 영양소 데이터
- **주요 엔드포인트:**
  ```
  GET /foods/search
    ?query={음식명}
    &api_key={API_KEY}
    &pageSize=10
  ```

### 3. Open Food Facts (바코드)
- **URL:** https://world.openfoodfacts.org/api/v2
- **인증:** 불필요 (무료 오픈 API)
- **용도:** 바코드 기반 가공식품 영양소 조회
- **주요 엔드포인트:**
  ```
  GET /product/{barcode}.json
  ```

### 4. OpenAI API (AI 기능 — Phase 5)
- **URL:** https://api.openai.com/v1
- **인증:** API 키 필요 (환경변수 `OPENAI_API_KEY`)
- **용도:** 자연어 음식 입력 파싱, 사진 인식
- **사용 모델:** gpt-4o

---

## ⚠️ API 키 보안 규칙
- 모든 API 키는 `.env` 파일에 저장
- `.env`는 `.gitignore`에 포함 → **절대 GitHub에 올리면 안 됨**
- Flutter에서는 `flutter_dotenv` 패키지로 로드
