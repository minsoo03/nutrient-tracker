import 'package:nutrient_tracker/models/food_model.dart';

/// 과자/라면 표준 영양 데이터 (100g 기준)
const snackNoodleCatalog = <String, FoodModel>{
  '과자': FoodModel(
    id: 'standard_snack',
    name: '과자',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 500, carbsG: 63, proteinG: 6, fatG: 25,
      sugarG: 7, fiberG: 2, sodiumMg: 450, caffeineMg: 0,
    ),
  ),
  '감자칩': FoodModel(
    id: 'standard_potato_chips',
    name: '감자칩',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 540, carbsG: 53, proteinG: 6, fatG: 35,
      sugarG: 3, fiberG: 4, sodiumMg: 520, caffeineMg: 0,
    ),
  ),
  '옥수수 스낵': FoodModel(
    id: 'standard_corn_snack',
    name: '옥수수 스낵',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 515, carbsG: 64, proteinG: 6, fatG: 26,
      sugarG: 6, fiberG: 3, sodiumMg: 480, caffeineMg: 0,
    ),
  ),
  '초코파이': FoodModel(
    id: 'standard_choco_pie',
    name: '초코파이',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 430, carbsG: 67, proteinG: 4.5, fatG: 16,
      sugarG: 34, fiberG: 1, sodiumMg: 220, caffeineMg: 0,
    ),
  ),
  '초코 과자': FoodModel(
    id: 'standard_choco_snack',
    name: '초코 과자',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 470, carbsG: 67, proteinG: 5, fatG: 20,
      sugarG: 32, fiberG: 2, sodiumMg: 260, caffeineMg: 0,
    ),
  ),
  '초코 케이크': FoodModel(
    id: 'standard_choco_cake',
    name: '초코 케이크',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 410, carbsG: 53, proteinG: 6, fatG: 19,
      sugarG: 28, fiberG: 1, sodiumMg: 280, caffeineMg: 0,
    ),
  ),
  '카스타드 케이크': FoodModel(
    id: 'standard_custard_cake',
    name: '카스타드 케이크',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 395, carbsG: 56, proteinG: 6, fatG: 16,
      sugarG: 25, fiberG: 1, sodiumMg: 250, caffeineMg: 0,
    ),
  ),
  '라면': FoodModel(
    id: 'standard_ramen',
    name: '라면',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 470, carbsG: 64, proteinG: 10, fatG: 19,
      sugarG: 3, fiberG: 3, sodiumMg: 1700, caffeineMg: 0,
    ),
  ),
  '볶음면': FoodModel(
    id: 'standard_spicy_noodles',
    name: '볶음면',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 430, carbsG: 61, proteinG: 9, fatG: 17,
      sugarG: 6, fiberG: 3, sodiumMg: 1400, caffeineMg: 0,
    ),
  ),
  '짜장라면': FoodModel(
    id: 'standard_black_bean_ramen',
    name: '짜장라면',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 440, carbsG: 66, proteinG: 8, fatG: 16,
      sugarG: 5, fiberG: 3, sodiumMg: 1250, caffeineMg: 0,
    ),
  ),
};
