import 'package:nutrient_tracker/models/food_model.dart';

/// 음료/빙과류 표준 영양 데이터 (100ml 또는 100g 기준)
const drinkCatalog = <String, FoodModel>{
  '에너지드링크': FoodModel(
    id: 'standard_energy_drink',
    name: '에너지드링크',
    source: 'standard',
    nutritionBasisLabel: '100ml',
    per100g: FoodNutrition(
      calories: 45, carbsG: 11, proteinG: 0.5, fatG: 0,
      sugarG: 11, fiberG: 0, sodiumMg: 50, caffeineMg: 32,
    ),
  ),
  '콜라': FoodModel(
    id: 'standard_cola',
    name: '콜라',
    source: 'standard',
    nutritionBasisLabel: '100ml',
    per100g: FoodNutrition(
      calories: 42, carbsG: 10.6, proteinG: 0, fatG: 0,
      sugarG: 10.6, fiberG: 0, sodiumMg: 4, caffeineMg: 10,
    ),
  ),
  '제로 콜라': FoodModel(
    id: 'standard_zero_cola',
    name: '제로 콜라',
    source: 'standard',
    nutritionBasisLabel: '100ml',
    per100g: FoodNutrition(
      calories: 1, carbsG: 0, proteinG: 0, fatG: 0,
      sugarG: 0, fiberG: 0, sodiumMg: 8, caffeineMg: 10,
    ),
  ),
  '사이다': FoodModel(
    id: 'standard_cider',
    name: '사이다',
    source: 'standard',
    nutritionBasisLabel: '100ml',
    per100g: FoodNutrition(
      calories: 42, carbsG: 10.5, proteinG: 0, fatG: 0,
      sugarG: 10.5, fiberG: 0, sodiumMg: 8, caffeineMg: 0,
    ),
  ),
  '오렌지 탄산음료': FoodModel(
    id: 'standard_orange_soda',
    name: '오렌지 탄산음료',
    source: 'standard',
    nutritionBasisLabel: '100ml',
    per100g: FoodNutrition(
      calories: 46, carbsG: 11.5, proteinG: 0, fatG: 0,
      sugarG: 11.3, fiberG: 0, sodiumMg: 12, caffeineMg: 0,
    ),
  ),
  '바나나 우유': FoodModel(
    id: 'standard_banana_milk',
    name: '바나나 우유',
    source: 'standard',
    nutritionBasisLabel: '100ml',
    per100g: FoodNutrition(
      calories: 72, carbsG: 10.8, proteinG: 2.1, fatG: 2.3,
      sugarG: 10.2, fiberG: 0, sodiumMg: 45, caffeineMg: 0,
    ),
  ),
  '아이스크림': FoodModel(
    id: 'standard_ice_cream',
    name: '아이스크림',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 210, carbsG: 25, proteinG: 3.5, fatG: 11,
      sugarG: 21, fiberG: 0, sodiumMg: 80, caffeineMg: 0,
    ),
  ),
  '아이스바': FoodModel(
    id: 'standard_popsicle',
    name: '아이스바',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 135, carbsG: 33, proteinG: 1, fatG: 1,
      sugarG: 24, fiberG: 0, sodiumMg: 40, caffeineMg: 0,
    ),
  ),
};
