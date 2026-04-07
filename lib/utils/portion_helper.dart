/// 음식 이름 키워드 → 일반적인 1회 섭취 단위 매핑
class PortionOption {
  final String label; // "1조각 (30g)"
  final double grams;

  const PortionOption(this.label, this.grams);
}

enum FoodUiCategory {
  generalFood,
  koreanMeal,
  beverage,
  caffeinatedDrink,
  alcoholicDrink,
  proteinSupplement,
}

class FoodInputProfile {
  final FoodUiCategory category;
  final bool usesMilliliters;
  final bool supportsZeroToggle;
  final bool supportsSugarInput;
  final bool supportsCaffeineInput;
  final bool supportsMealCompanions;

  const FoodInputProfile({
    required this.category,
    required this.usesMilliliters,
    required this.supportsZeroToggle,
    required this.supportsSugarInput,
    required this.supportsCaffeineInput,
    required this.supportsMealCompanions,
  });
}

class PortionHelper {
  static const _map = <String, List<PortionOption>>{
    // ── 곡류 ─────────────────────────────
    'rice|밥|쌀': [
      PortionOption('1공기 (210g)', 210),
      PortionOption('반공기 (105g)', 105),
      PortionOption('1/3공기 (70g)', 70),
    ],
    'bread|빵|toast|토스트': [
      PortionOption('1조각 (30g)', 30),
      PortionOption('2조각 (60g)', 60),
      PortionOption('3조각 (90g)', 90),
    ],
    'noodle|pasta|면|라면|국수|파스타': [
      PortionOption('1인분 (100g 건면)', 100),
      PortionOption('1인분 (200g 조리 후)', 200),
    ],
    'oat|오트밀': [
      PortionOption('1회분 (40g 건)', 40),
      PortionOption('1회분 (80g 조리 후)', 80),
    ],
    'cereal|시리얼|granola|그래놀라': [
      PortionOption('1회분 (30g)', 30),
      PortionOption('1그릇 (40g)', 40),
      PortionOption('넉넉하게 (60g)', 60),
    ],
    'protein shake|protein drink|protein powder|whey protein|프로틴|단백질쉐이크|단백질 보충제': [
      PortionOption('1스쿱 (30g)', 30),
      PortionOption('1회분 (40g)', 40),
      PortionOption('진하게 (60g)', 60),
    ],
    // ── 단백질 ──────────────────────────
    'egg|계란|달걀': [
      PortionOption('1개 소 (40g)', 40),
      PortionOption('1개 중 (50g)', 50),
      PortionOption('1개 대 (60g)', 60),
      PortionOption('2개 (100g)', 100),
    ],
    'chicken|닭|치킨': [
      PortionOption('1쪽 가슴살 (150g)', 150),
      PortionOption('1쪽 허벅지 (100g)', 100),
      PortionOption('1인분 (200g)', 200),
    ],
    'beef|소고기|스테이크': [
      PortionOption('1인분 (150g)', 150),
      PortionOption('1인분 (200g)', 200),
    ],
    'pork|돼지|삼겹살': [
      PortionOption('1인분 (150g)', 150),
      PortionOption('1인분 (200g)', 200),
    ],
    'fish|생선|연어|참치|salmon|tuna': [
      PortionOption('1토막 (100g)', 100),
      PortionOption('1토막 (150g)', 150),
    ],
    // ── 유제품 ──────────────────────────
    'milk|우유': [
      PortionOption('1컵 (200ml)', 200),
      PortionOption('반컵 (100ml)', 100),
    ],
    'yogurt|요거트|요구르트': [
      PortionOption('1개 소 (100g)', 100),
      PortionOption('1개 대 (200g)', 200),
    ],
    'cheese|치즈': [
      PortionOption('1장 (20g)', 20),
      PortionOption('2장 (40g)', 40),
    ],
    // ── 과일 ────────────────────────────
    'banana|바나나': [
      PortionOption('1개 소 (80g)', 80),
      PortionOption('1개 중 (100g)', 100),
      PortionOption('1개 대 (120g)', 120),
    ],
    'apple|사과': [
      PortionOption('1개 소 (150g)', 150),
      PortionOption('1개 중 (200g)', 200),
      PortionOption('반개 (100g)', 100),
    ],
    'orange|귤|오렌지': [
      PortionOption('1개 (100g)', 100),
      PortionOption('1개 (150g)', 150),
    ],
    // ── 채소 ────────────────────────────
    'salad|샐러드': [
      PortionOption('1접시 (100g)', 100),
      PortionOption('1접시 (150g)', 150),
    ],
    '찌개|전골|국밥|해장국|미역국|곰탕|설렁탕|갈비탕|삼계탕|도가니탕|육개장|순두부|마라탕|훠궈|스프|soup|stew': [
      PortionOption('반 그릇 (200g)', 200),
      PortionOption('1인분 (300g)', 300),
      PortionOption('큰 그릇 (500g)', 500),
    ],
    // ── 음료 ────────────────────────────
    'coffee|커피|아메리카노|라떼': [
      PortionOption('1잔 Small (240ml)', 240),
      PortionOption('1잔 Grande (355ml)', 355),
      PortionOption('1잔 Venti (473ml)', 473),
    ],
    'juice|주스': [
      PortionOption('1컵 (200ml)', 200),
      PortionOption('1병 (350ml)', 350),
    ],
    '에너지드링크|energy drink|energydrink|monster|red bull|redbull|핫식스|박카스': [
      PortionOption('반 캔 (125ml)', 125),
      PortionOption('1캔 (250ml)', 250),
      PortionOption('큰 캔 (355ml)', 355),
      PortionOption('대용량 (500ml)', 500),
    ],
    'cola|coke|콜라|soda|탄산|사이다|sprite|fanta|pepsi': [
      PortionOption('반 캔 (125ml)', 125),
      PortionOption('1캔 (250ml)', 250),
      PortionOption('355ml 캔', 355),
      PortionOption('500ml 병', 500),
    ],
    '술|소주|soju': [
      PortionOption('1잔 (50ml)', 50),
      PortionOption('2잔 (100ml)', 100),
      PortionOption('반 병 (180ml)', 180),
      PortionOption('1병 (360ml)', 360),
    ],
    '맥주|beer|lager': [
      PortionOption('반 캔 (250ml)', 250),
      PortionOption('1캔 (500ml)', 500),
      PortionOption('생맥 1잔 (425ml)', 425),
      PortionOption('큰잔 (1000ml)', 1000),
    ],
    '와인|wine': [
      PortionOption('1잔 (150ml)', 150),
      PortionOption('2잔 (300ml)', 300),
      PortionOption('반 병 (375ml)', 375),
      PortionOption('1병 (750ml)', 750),
    ],
    '막걸리|makgeolli': [
      PortionOption('1잔 (200ml)', 200),
      PortionOption('반 병 (375ml)', 375),
      PortionOption('1병 (750ml)', 750),
    ],
    '위스키|whiskey|whisky': [
      PortionOption('1샷 (30ml)', 30),
      PortionOption('2샷 (60ml)', 60),
      PortionOption('온더락스 1잔 (60ml)', 60),
    ],
    '하이볼|highball': [
      PortionOption('1잔 (300ml)', 300),
      PortionOption('큰잔 (450ml)', 450),
    ],
    'tea|차|녹차|홍차|밀크티': [
      PortionOption('1잔 (240ml)', 240),
      PortionOption('1병 (350ml)', 350),
      PortionOption('대용량 (500ml)', 500),
    ],
  };

  static const _liquidKeywords = [
    'coffee',
    '커피',
    '아메리카노',
    '라떼',
    'juice',
    '주스',
    '에너지드링크',
    'energy drink',
    'energydrink',
    'monster',
    'red bull',
    'redbull',
    '핫식스',
    '박카스',
    'cola',
    'coke',
    '콜라',
    'soda',
    '탄산',
    '사이다',
    'sprite',
    'fanta',
    'pepsi',
    'tea',
    '차',
    '녹차',
    '홍차',
    '밀크티',
    '술',
    '소주',
    'soju',
    '맥주',
    'beer',
    'lager',
    '와인',
    'wine',
    '막걸리',
    'makgeolli',
    '위스키',
    'whiskey',
    'whisky',
    '하이볼',
    'highball',
    'drink',
    '음료',
    '음료수',
  ];

  static const _koreanMealKeywords = [
    '찌개',
    '전골',
    '덮밥',
    '백반',
    '정식',
    '볶음밥',
    '비빔밥',
    '국밥',
    '해장국',
    '미역국',
    '곰탕',
    '설렁탕',
    '김치찌개',
    '된장찌개',
    '순두부',
    '육개장',
    '갈비탕',
    '삼계탕',
    '도가니탕',
    '마라탕',
    '훠궈',
  ];

  static const _alcoholKeywords = [
    '술',
    '소주',
    'soju',
    '맥주',
    'beer',
    'lager',
    '와인',
    'wine',
    '막걸리',
    'makgeolli',
    '위스키',
    'whiskey',
    'whisky',
    '하이볼',
    'highball',
  ];

  static const _caffeinatedDrinkKeywords = [
    'coffee',
    '커피',
    '아메리카노',
    '라떼',
    '에너지드링크',
    'energy drink',
    'energydrink',
    'monster',
    'red bull',
    'redbull',
    '핫식스',
    '박카스',
    'cola',
    'coke',
    '콜라',
    'pepsi',
    '펩시',
    'tea',
    '차',
    '녹차',
    '홍차',
    '밀크티',
  ];

  static const _sweetDrinkKeywords = [
    'juice',
    '주스',
    'cola',
    'coke',
    '콜라',
    'soda',
    '탄산',
    '사이다',
    'sprite',
    'fanta',
    'pepsi',
    '에너지드링크',
    'energy drink',
    'energydrink',
    'monster',
    'red bull',
    'redbull',
    '핫식스',
    '박카스',
    'tea',
    '차',
    '밀크티',
    'drink',
    '음료',
    '음료수',
  ];

  static const _proteinKeywords = [
    'protein shake',
    'protein drink',
    'protein powder',
    'whey protein',
    '프로틴',
    '단백질쉐이크',
    '단백질 보충제',
  ];

  /// 음식 이름에 맞는 기본 섭취량 목록 반환
  /// 없으면 빈 리스트 (→ 직접 입력만 제공)
  static List<PortionOption> getPortions(String foodName) {
    final lower = foodName.toLowerCase();
    for (final entry in _map.entries) {
      final keywords = entry.key.split('|');
      if (keywords.any((kw) => lower.contains(kw))) {
        return entry.value;
      }
    }
    return [];
  }

  static bool usesMilliliters(String foodName) {
    return inputProfileFor(foodName).usesMilliliters;
  }

  static FoodInputProfile inputProfileFor(String foodName) {
    final lower = foodName.toLowerCase();

    if (_containsAny(lower, _alcoholKeywords)) {
      return const FoodInputProfile(
        category: FoodUiCategory.alcoholicDrink,
        usesMilliliters: true,
        supportsZeroToggle: false,
        supportsSugarInput: false,
        supportsCaffeineInput: false,
        supportsMealCompanions: false,
      );
    }

    if (_containsAny(lower, _koreanMealKeywords)) {
      return const FoodInputProfile(
        category: FoodUiCategory.koreanMeal,
        usesMilliliters: false,
        supportsZeroToggle: false,
        supportsSugarInput: false,
        supportsCaffeineInput: false,
        supportsMealCompanions: true,
      );
    }

    if (_containsAny(lower, _proteinKeywords)) {
      return const FoodInputProfile(
        category: FoodUiCategory.proteinSupplement,
        usesMilliliters: false,
        supportsZeroToggle: false,
        supportsSugarInput: false,
        supportsCaffeineInput: false,
        supportsMealCompanions: false,
      );
    }

    if (_containsAny(lower, _caffeinatedDrinkKeywords)) {
      return FoodInputProfile(
        category: FoodUiCategory.caffeinatedDrink,
        usesMilliliters: true,
        supportsZeroToggle: _containsAny(lower, _sweetDrinkKeywords),
        supportsSugarInput: _containsAny(lower, _sweetDrinkKeywords),
        supportsCaffeineInput: true,
        supportsMealCompanions: false,
      );
    }

    if (_containsAny(lower, _sweetDrinkKeywords) || _containsAny(lower, _liquidKeywords)) {
      return const FoodInputProfile(
        category: FoodUiCategory.beverage,
        usesMilliliters: true,
        supportsZeroToggle: true,
        supportsSugarInput: true,
        supportsCaffeineInput: false,
        supportsMealCompanions: false,
      );
    }

    return const FoodInputProfile(
      category: FoodUiCategory.generalFood,
      usesMilliliters: false,
      supportsZeroToggle: false,
      supportsSugarInput: false,
      supportsCaffeineInput: false,
      supportsMealCompanions: false,
    );
  }

  static bool _containsAny(String lower, List<String> keywords) {
    return keywords.any(lower.contains);
  }
}
