import 'package:nutrient_tracker/models/food_model.dart';

class MealCompanionOption {
  final String key;
  final String label;
  final FoodNutrition nutrition;
  const MealCompanionOption({
    required this.key,
    required this.label,
    required this.nutrition,
  });
}

const kNoneNutrition = FoodNutrition(
  calories: 0, carbsG: 0, proteinG: 0, fatG: 0,
  sugarG: 0, fiberG: 0, sodiumMg: 0, caffeineMg: 0, alcoholG: 0,
);

const riceOptions = [
  MealCompanionOption(key: 'none', label: '밥 없음', nutrition: kNoneNutrition),
  MealCompanionOption(
    key: 'half', label: '반 공기',
    nutrition: FoodNutrition(
      calories: 150, carbsG: 33, proteinG: 3, fatG: 0.4,
      sugarG: 0, fiberG: 0.5, sodiumMg: 2, caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'full', label: '한 공기',
    nutrition: FoodNutrition(
      calories: 300, carbsG: 66, proteinG: 6, fatG: 0.8,
      sugarG: 0, fiberG: 1, sodiumMg: 4, caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'double', label: '두 공기',
    nutrition: FoodNutrition(
      calories: 600, carbsG: 132, proteinG: 12, fatG: 1.6,
      sugarG: 0, fiberG: 2, sodiumMg: 8, caffeineMg: 0,
    ),
  ),
  MealCompanionOption(key: 'custom', label: '직접 입력', nutrition: kNoneNutrition),
];

const sideDishOptions = [
  MealCompanionOption(key: 'none', label: '반찬 없음', nutrition: kNoneNutrition),
  MealCompanionOption(
    key: 'light', label: '반찬 조금',
    nutrition: FoodNutrition(
      calories: 80, carbsG: 6, proteinG: 3, fatG: 4,
      sugarG: 2, fiberG: 1.5, sodiumMg: 220, caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'normal', label: '반찬 보통',
    nutrition: FoodNutrition(
      calories: 160, carbsG: 12, proteinG: 6, fatG: 8,
      sugarG: 3, fiberG: 3, sodiumMg: 450, caffeineMg: 0,
    ),
  ),
];

MealCompanionOption resolvedRiceOption(
  MealCompanionOption selectedRice,
  String customRiceValue,
) {
  if (selectedRice.key != 'custom') return selectedRice;
  final bowls = double.tryParse(customRiceValue.trim()) ?? 0;
  if (bowls <= 0) {
    return const MealCompanionOption(
      key: 'none', label: '밥 없음', nutrition: kNoneNutrition,
    );
  }
  return MealCompanionOption(
    key: 'custom',
    label: '${bowls.toStringAsFixed(bowls % 1 == 0 ? 0 : 1)}공기',
    nutrition: FoodNutrition(
      calories: 300 * bowls, carbsG: 66 * bowls,
      proteinG: 6 * bowls, fatG: 0.8 * bowls,
      sugarG: 0, fiberG: 1 * bowls, sodiumMg: 4 * bowls, caffeineMg: 0,
    ),
  );
}

String? buildCompanionLabel(
  MealCompanionOption rice,
  MealCompanionOption sideDish,
) {
  final parts = <String>[];
  if (rice.key != 'none') parts.add(rice.label);
  if (sideDish.key != 'none') parts.add(sideDish.label);
  if (parts.isEmpty) return null;
  return parts.join(' + ');
}

double? resolveCustomAmount(String foodName, String rawValue) {
  // Import is done by callers; this is a pure helper
  final value = double.tryParse(rawValue.trim());
  return value;
}
