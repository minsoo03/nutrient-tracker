import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/data/food_snack_noodle_catalog.dart';
import 'package:nutrient_tracker/data/food_drink_catalog.dart';
import 'package:nutrient_tracker/data/food_meal_catalog.dart';

export 'food_aliases.dart';
export 'food_snack_noodle_catalog.dart';
export 'food_drink_catalog.dart';
export 'food_alcohol_data.dart';
export 'food_meal_catalog.dart';

/// 브랜드/표준 음식 카탈로그 (과자 + 라면 + 음료 + 일반 음식 통합)
/// 키: 표준 음식명, 값: 표준 FoodModel
final brandCatalog = <String, FoodModel>{
  ...snackNoodleCatalog,
  ...drinkCatalog,
  ...mealCatalog,
};
