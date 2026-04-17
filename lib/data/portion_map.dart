/// 음식 키워드 → 1회 섭취 단위 매핑
/// ⚠️ 복합 요리명(만두국, 감자탕)을 재료명(만두, 감자)보다 반드시 앞에 배치
/// 음료/술 → portion_map_drinks.dart

class PortionOption {
  final String label;
  final double grams;
  const PortionOption(this.label, this.grams);
}

const kPortionMapFood = <String, List<PortionOption>>{
  // ── 복합 요리 최상단 (재료명과 충돌 방지) ─────────────────────
  '만두국|떡만두국|떡국': [
    PortionOption('반 그릇 (200g)', 200), PortionOption('1인분 (350g)', 350),
    PortionOption('큰 그릇 (500g)', 500),
  ],
  '감자탕|닭볶음탕|닭갈비탕|해물탕|부대찌개|순댓국|순대국밥': [
    PortionOption('반 그릇 (250g)', 250), PortionOption('1인분 (400g)', 400),
    PortionOption('큰 그릇 (600g)', 600),
  ],
  '소고기국밥|돼지국밥|콩나물국밥': [
    PortionOption('1그릇 소 (400g)', 400), PortionOption('1그릇 중 (550g)', 550),
    PortionOption('1그릇 대 (700g)', 700),
  ],
  '콩나물국|북엇국|시금치국|소고기국|미소국': [
    PortionOption('반 그릇 (150g)', 150), PortionOption('1그릇 (250g)', 250),
  ],
  '닭갈비|닭볶음|오삼볶음|제육볶음|소불고기|돼지불고기': [
    PortionOption('1인분 (150g)', 150), PortionOption('1인분 (200g)', 200),
    PortionOption('2인분 (400g)', 400),
  ],
  '족발|보쌈|수육|편육': [
    PortionOption('소 1인분 (150g)', 150), PortionOption('1인분 (200g)', 200),
    PortionOption('2인분 (400g)', 400),
  ],
  // ── 밥/곡물 ──────────────────────────────────────────────────
  'rice|밥|쌀': [
    PortionOption('1공기 (210g)', 210), PortionOption('반공기 (105g)', 105),
    PortionOption('1/3공기 (70g)', 70),
  ],
  '빵|bread|toast|토스트': [
    PortionOption('1조각 (30g)', 30), PortionOption('2조각 (60g)', 60),
    PortionOption('3조각 (90g)', 90),
  ],
  '컵라면|컵면|cup noodle': [
    PortionOption('1개 소 (65g)', 65), PortionOption('1개 (90g)', 90),
    PortionOption('큰 사발 (110g)', 110),
  ],
  '라면|봉지라면|ramen': [PortionOption('1봉지 (120g)', 120), PortionOption('2봉지 (240g)', 240)],
  '면|국수|파스타|noodle|pasta': [PortionOption('1인분 (100g)', 100), PortionOption('1인분 (200g)', 200)],
  '김밥': [
    PortionOption('1줄 (240g)', 240), PortionOption('반줄 (120g)', 120),
    PortionOption('1개 (30g)', 30),
  ],
  'oat|오트밀': [PortionOption('1회분 (40g)', 40), PortionOption('큰 그릇 (80g)', 80)],
  'cereal|시리얼|granola|그래놀라': [
    PortionOption('1회분 (30g)', 30), PortionOption('1그릇 (40g)', 40),
    PortionOption('넉넉하게 (60g)', 60),
  ],
  // ── 육류/단백질 ───────────────────────────────────────────────
  '닭가슴살|chicken breast': [
    PortionOption('소 1개 (100g)', 100), PortionOption('대 1개 (150g)', 150),
    PortionOption('2개 (200g)', 200),
  ],
  'egg|계란|달걀': [
    PortionOption('1개 소 (40g)', 40), PortionOption('1개 중 (50g)', 50),
    PortionOption('1개 대 (60g)', 60), PortionOption('2개 (100g)', 100),
  ],
  'protein shake|whey protein|프로틴|단백질쉐이크|단백질 보충제': [
    PortionOption('1스쿱 (30g)', 30), PortionOption('1회분 (40g)', 40),
    PortionOption('진하게 (60g)', 60),
  ],
  'chicken|닭|치킨': [
    PortionOption('1쪽 가슴살 (150g)', 150), PortionOption('1쪽 허벅지 (100g)', 100),
    PortionOption('1인분 (200g)', 200),
  ],
  'beef|소고기|스테이크': [PortionOption('1인분 (150g)', 150), PortionOption('1인분 (200g)', 200)],
  '삼겹살|pork belly': [PortionOption('1인분 (150g)', 150), PortionOption('2인분 (300g)', 300)],
  'pork|돼지': [PortionOption('1인분 (150g)', 150), PortionOption('1인분 (200g)', 200)],
  '연어|salmon': [PortionOption('1토막 소 (80g)', 80), PortionOption('1토막 대 (150g)', 150)],
  'fish|생선|참치|tuna': [PortionOption('1토막 (100g)', 100), PortionOption('1토막 (150g)', 150)],
  '참치캔|참치 캔|canned tuna': [PortionOption('소 1캔 (85g)', 85), PortionOption('중 1캔 (135g)', 135)],
  '스팸|spam|햄|ham': [
    PortionOption('1조각 (30g)', 30), PortionOption('3조각 (90g)', 90),
    PortionOption('1캔 (340g)', 340),
  ],
  '만두|dumpling': [
    PortionOption('1개 (30g)', 30), PortionOption('3개 (90g)', 90),
    PortionOption('5개 (150g)', 150), PortionOption('10개 (300g)', 300),
  ],
  '소시지|sausage|핫도그|hotdog': [
    PortionOption('1개 소 (50g)', 50), PortionOption('1개 중 (80g)', 80),
    PortionOption('2개 (160g)', 160),
  ],
  '두부|tofu': [
    PortionOption('1조각 (50g)', 50), PortionOption('반모 (150g)', 150),
    PortionOption('1모 (300g)', 300),
  ],
  // ── 유제품 ────────────────────────────────────────────────────
  'milk|우유': [
    PortionOption('반컵 (100ml)', 100), PortionOption('1컵 (200ml)', 200),
    PortionOption('1팩 (200ml)', 200),
  ],
  'yogurt|요거트|요구르트': [PortionOption('1개 소 (100g)', 100), PortionOption('1개 대 (200g)', 200)],
  'cheese|치즈': [PortionOption('1장 (20g)', 20), PortionOption('2장 (40g)', 40)],
  // ── 과일/채소 ─────────────────────────────────────────────────
  'banana|바나나': [
    PortionOption('1개 소 (80g)', 80), PortionOption('1개 중 (100g)', 100),
    PortionOption('1개 대 (120g)', 120),
  ],
  'apple|사과': [
    PortionOption('반개 (100g)', 100), PortionOption('1개 소 (150g)', 150),
    PortionOption('1개 중 (200g)', 200),
  ],
  'orange|귤|오렌지': [PortionOption('1개 소 (100g)', 100), PortionOption('1개 대 (150g)', 150)],
  '고구마|sweet potato': [
    PortionOption('소 1개 (80g)', 80), PortionOption('중 1개 (130g)', 130),
    PortionOption('대 1개 (200g)', 200),
  ],
  '감자|potato': [
    PortionOption('소 1개 (70g)', 70), PortionOption('중 1개 (130g)', 130),
    PortionOption('대 1개 (200g)', 200),
  ],
  '아보카도|avocado': [PortionOption('반개 (75g)', 75), PortionOption('1개 (150g)', 150)],
  '토마토|tomato': [
    PortionOption('소 1개 (80g)', 80), PortionOption('중 1개 (120g)', 120),
    PortionOption('대 1개 (200g)', 200),
  ],
  '딸기|strawberry': [
    PortionOption('1개 (10g)', 10), PortionOption('5개 (50g)', 50),
    PortionOption('10개 (100g)', 100),
  ],
  '포도|grape': [PortionOption('10알 (50g)', 50), PortionOption('한송이 (200g)', 200)],
  '수박|watermelon': [PortionOption('1조각 소 (150g)', 150), PortionOption('1조각 대 (250g)', 250)],
  '복숭아|peach': [PortionOption('반개 (75g)', 75), PortionOption('1개 (150g)', 150)],
  '망고|mango': [PortionOption('반개 (100g)', 100), PortionOption('1개 (200g)', 200)],
  'salad|샐러드': [PortionOption('1접시 소 (100g)', 100), PortionOption('1접시 대 (200g)', 200)],
  // ── 탕/국/찌개 ────────────────────────────────────────────────
  '찌개|전골|국밥|해장국|미역국|곰탕|설렁탕|갈비탕|삼계탕|육개장|순두부|마라탕|훠궈|스프|soup|stew': [
    PortionOption('반 그릇 (200g)', 200), PortionOption('1인분 (300g)', 300),
    PortionOption('큰 그릇 (500g)', 500),
  ],
  // ── 패스트푸드/외식 ───────────────────────────────────────────
  '햄버거|burger': [
    PortionOption('1개 소 (150g)', 150), PortionOption('1개 중 (200g)', 200),
    PortionOption('1개 대 (250g)', 250),
  ],
  '피자|pizza': [
    PortionOption('1조각 (100g)', 100), PortionOption('2조각 (200g)', 200),
    PortionOption('반판 (300g)', 300),
  ],
  '도시락': [
    PortionOption('소 1개 (300g)', 300), PortionOption('중 1개 (500g)', 500),
    PortionOption('대 1개 (700g)', 700),
  ],
  // ── 스낵/과자 ─────────────────────────────────────────────────
  '과자|스낵|칩|chip|snack|crackers|크래커|포카칩|새우깡|꼬깔콘|프링글스': [
    PortionOption('소봉지 (30g)', 30), PortionOption('1봉지 (60g)', 60),
    PortionOption('대봉지 (120g)', 120),
  ],
  '초콜릿|chocolate': [
    PortionOption('1조각 (10g)', 10), PortionOption('3조각 (30g)', 30),
    PortionOption('반판 (50g)', 50), PortionOption('1판 (100g)', 100),
  ],
  '사탕|candy|캔디|lollipop': [
    PortionOption('1개 (5g)', 5), PortionOption('3개 (15g)', 15), PortionOption('한줌 (30g)', 30),
  ],
  '젤리|gummy|구미': [
    PortionOption('1개 (5g)', 5), PortionOption('5개 (25g)', 25), PortionOption('1봉지 (50g)', 50),
  ],
  '쿠키|cookie|비스킷|biscuit|오레오': [
    PortionOption('1개 (15g)', 15), PortionOption('3개 (45g)', 45), PortionOption('1봉지 (80g)', 80),
  ],
  // ── 디저트 ────────────────────────────────────────────────────
  '아이스크림|ice cream|아이스': [
    PortionOption('1개 바 (70g)', 70), PortionOption('1개 콘 (110g)', 110),
    PortionOption('1컵 (130g)', 130),
  ],
  '케이크|cake': [
    PortionOption('1조각 소 (80g)', 80), PortionOption('1조각 대 (120g)', 120),
    PortionOption('2조각 (200g)', 200),
  ],
  '도넛|doughnut|donut': [
    PortionOption('1개 소 (50g)', 50), PortionOption('1개 중 (70g)', 70),
    PortionOption('2개 (120g)', 120),
  ],
  '마카롱|macaron': [
    PortionOption('1개 (20g)', 20), PortionOption('2개 (40g)', 40), PortionOption('3개 (60g)', 60),
  ],
};
