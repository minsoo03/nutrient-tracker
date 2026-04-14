import 'package:nutrient_tracker/models/food_model.dart';

/// 자주 검색되는 일반 음식 표준 영양 데이터.
///
/// 공공 API가 검색어와 무관한 결과를 반환하거나, 외식 메뉴처럼 기준량이
/// 들쭉날쭉한 경우 앱에서 먼저 보여줄 평균값이다. 모두 100g 기준.
const mealCatalog = <String, FoodModel>{
  '치킨': FoodModel(
    id: 'standard_chicken',
    name: '치킨',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 270,
      carbsG: 8,
      proteinG: 19,
      fatG: 18,
      sugarG: 0.5,
      fiberG: 0.5,
      sodiumMg: 620,
      caffeineMg: 0,
      alcoholG: 0,
    ),
  ),
  '후라이드 치킨': FoodModel(
    id: 'standard_fried_chicken',
    name: '후라이드 치킨',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 285,
      carbsG: 9,
      proteinG: 20,
      fatG: 19,
      sugarG: 0.7,
      fiberG: 0.5,
      sodiumMg: 650,
      caffeineMg: 0,
      alcoholG: 0,
    ),
  ),
  '양념치킨': FoodModel(
    id: 'standard_seasoned_chicken',
    name: '양념치킨',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 305,
      carbsG: 18,
      proteinG: 18,
      fatG: 18,
      sugarG: 9,
      fiberG: 0.7,
      sodiumMg: 720,
      caffeineMg: 0,
      alcoholG: 0,
    ),
  ),
};
