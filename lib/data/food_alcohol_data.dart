import 'package:nutrient_tracker/models/food_model.dart';

/// 주류 표준 영양 데이터 (100ml 기준)
const kSoju = FoodModel(
  id: 'standard_soju', name: '소주', source: 'standard',
  nutritionBasisLabel: '100ml',
  per100g: FoodNutrition(
    calories: 130, carbsG: 0.8, proteinG: 0, fatG: 0,
    sugarG: 0, fiberG: 0, sodiumMg: 1, caffeineMg: 0, alcoholG: 17,
  ),
);

const kBeer = FoodModel(
  id: 'standard_beer', name: '맥주', source: 'standard',
  nutritionBasisLabel: '100ml',
  per100g: FoodNutrition(
    calories: 43, carbsG: 3.6, proteinG: 0.4, fatG: 0,
    sugarG: 0.3, fiberG: 0, sodiumMg: 4, caffeineMg: 0, alcoholG: 4.3,
  ),
);

const kWine = FoodModel(
  id: 'standard_wine', name: '와인', source: 'standard',
  nutritionBasisLabel: '100ml',
  per100g: FoodNutrition(
    calories: 85, carbsG: 2.6, proteinG: 0.1, fatG: 0,
    sugarG: 0.8, fiberG: 0, sodiumMg: 5, caffeineMg: 0, alcoholG: 10.5,
  ),
);

const kMakgeolli = FoodModel(
  id: 'standard_makgeolli', name: '막걸리', source: 'standard',
  nutritionBasisLabel: '100ml',
  per100g: FoodNutrition(
    calories: 70, carbsG: 11, proteinG: 1.5, fatG: 0.2,
    sugarG: 2.5, fiberG: 0, sodiumMg: 6, caffeineMg: 0, alcoholG: 6,
  ),
);

const kWhiskey = FoodModel(
  id: 'standard_whiskey', name: '위스키', source: 'standard',
  nutritionBasisLabel: '100ml',
  per100g: FoodNutrition(
    calories: 250, carbsG: 0.1, proteinG: 0, fatG: 0,
    sugarG: 0, fiberG: 0, sodiumMg: 0, caffeineMg: 0, alcoholG: 40,
  ),
);

const kHighball = FoodModel(
  id: 'standard_highball', name: '하이볼', source: 'standard',
  nutritionBasisLabel: '100ml',
  per100g: FoodNutrition(
    calories: 75, carbsG: 3, proteinG: 0, fatG: 0,
    sugarG: 2.5, fiberG: 0, sodiumMg: 3, caffeineMg: 0, alcoholG: 7,
  ),
);

const kFriedEgg = FoodModel(
  id: 'standard_fried_egg', name: '계란 후라이', source: 'standard',
  nutritionBasisLabel: '100g',
  per100g: FoodNutrition(
    calories: 196, carbsG: 1.1, proteinG: 13.6, fatG: 15.0,
    sugarG: 0.7, fiberG: 0, sodiumMg: 180, caffeineMg: 0, alcoholG: 0,
  ),
);

const kBoiledEgg = FoodModel(
  id: 'standard_boiled_egg', name: '삶은 계란', source: 'standard',
  nutritionBasisLabel: '100g',
  per100g: FoodNutrition(
    calories: 155, carbsG: 1.1, proteinG: 13.0, fatG: 10.6,
    sugarG: 0.6, fiberG: 0, sodiumMg: 124, caffeineMg: 0, alcoholG: 0,
  ),
);

const kRawEgg = FoodModel(
  id: 'standard_raw_egg', name: '계란 (생)', source: 'standard',
  nutritionBasisLabel: '100g',
  per100g: FoodNutrition(
    calories: 143, carbsG: 0.7, proteinG: 12.6, fatG: 9.5,
    sugarG: 0.4, fiberG: 0, sodiumMg: 142, caffeineMg: 0, alcoholG: 0,
  ),
);

const kScrambledEgg = FoodModel(
  id: 'standard_scrambled_egg', name: '스크램블 에그', source: 'standard',
  nutritionBasisLabel: '100g',
  per100g: FoodNutrition(
    calories: 149, carbsG: 1.3, proteinG: 10.1, fatG: 11.2,
    sugarG: 0.6, fiberG: 0, sodiumMg: 150, caffeineMg: 0, alcoholG: 0,
  ),
);

const kProteinShake = FoodModel(
  id: 'standard_protein_shake', name: '프로틴 쉐이크', source: 'standard',
  nutritionBasisLabel: '100g',
  per100g: FoodNutrition(
    calories: 380, carbsG: 12, proteinG: 75, fatG: 6,
    sugarG: 5, fiberG: 1, sodiumMg: 220, caffeineMg: 0, alcoholG: 0,
  ),
);

/// 주류 카탈로그 (키워드 목록, FoodModel)
/// 키워드 중 하나라도 포함되면 해당 모델 반환
const alcoholCatalogEntries = <(List<String>, FoodModel)>[
  (['술', '소주', 'soju'], kSoju),
  (['술', '맥주', 'beer', 'lager'], kBeer),
  (['술', '와인', 'wine'], kWine),
  (['술', '막걸리', 'makgeolli', 'ricewine'], kMakgeolli),
  (['술', '위스키', 'whiskey', 'whisky'], kWhiskey),
  (['술', '하이볼', 'highball'], kHighball),
];
