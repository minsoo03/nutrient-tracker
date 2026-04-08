/// 음식 UI 카테고리 분류
enum FoodUiCategory {
  generalFood,
  koreanMeal,
  beverage,
  caffeinatedDrink,
  alcoholicDrink,
  proteinSupplement,
}

/// 음식 종류별 입력 프로필 (어떤 UI 옵션을 보여줄지 결정)
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

/// 음식 이름 → FoodInputProfile 분류 로직
class FoodInputClassifier {
  static const _liquidKeywords = [
    'coffee', '커피', '아메리카노', '라떼', 'juice', '주스',
    '에너지드링크', 'energy drink', 'energydrink', 'monster',
    'red bull', 'redbull', '핫식스', '박카스',
    'cola', 'coke', '콜라', 'soda', '탄산', '사이다', 'sprite', 'fanta', 'pepsi',
    'tea', '차', '녹차', '홍차', '밀크티',
    '술', '소주', 'soju', '맥주', 'beer', 'lager', '와인', 'wine',
    '막걸리', 'makgeolli', '위스키', 'whiskey', 'whisky', '하이볼', 'highball',
    'drink', '음료', '음료수',
  ];

  static const _koreanMealKeywords = [
    '찌개', '전골', '덮밥', '백반', '정식', '볶음밥', '비빔밥', '국밥',
    '해장국', '미역국', '곰탕', '설렁탕', '김치찌개', '된장찌개',
    '순두부', '육개장', '갈비탕', '삼계탕', '도가니탕', '마라탕', '훠궈',
  ];

  static const _alcoholKeywords = [
    '술', '소주', 'soju', '맥주', 'beer', 'lager',
    '와인', 'wine', '막걸리', 'makgeolli',
    '위스키', 'whiskey', 'whisky', '하이볼', 'highball',
  ];

  static const _caffeinatedDrinkKeywords = [
    'coffee', '커피', '아메리카노', '라떼',
    '에너지드링크', 'energy drink', 'energydrink', 'monster',
    'red bull', 'redbull', '핫식스', '박카스',
    'cola', 'coke', '콜라', 'pepsi', '펩시',
    'tea', '차', '녹차', '홍차', '밀크티',
  ];

  static const _sweetDrinkKeywords = [
    'juice', '주스', 'cola', 'coke', '콜라', 'soda', '탄산',
    '사이다', 'sprite', 'fanta', 'pepsi',
    '에너지드링크', 'energy drink', 'energydrink', 'monster',
    'red bull', 'redbull', '핫식스', '박카스',
    'tea', '차', '밀크티', 'drink', '음료', '음료수',
  ];

  static const _proteinKeywords = [
    'protein shake', 'protein drink', 'protein powder', 'whey protein',
    '프로틴', '단백질쉐이크', '단백질 보충제',
  ];

  /// 음식 이름으로 입력 프로필 판단
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

    if (_containsAny(lower, _sweetDrinkKeywords) ||
        _containsAny(lower, _liquidKeywords)) {
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
