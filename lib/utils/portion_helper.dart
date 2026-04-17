import 'package:nutrient_tracker/data/portion_map.dart';
import 'package:nutrient_tracker/data/portion_map_drinks.dart';
import 'package:nutrient_tracker/utils/food_input_profile.dart';

export 'package:nutrient_tracker/data/portion_map.dart' show PortionOption;
export 'package:nutrient_tracker/utils/food_input_profile.dart'
    show FoodUiCategory, FoodInputProfile;

class PortionHelper {
  static const double _defaultEggPieceGrams = 50;

  static const _fallbackGram = [
    PortionOption('조금 (50g)', 50),
    PortionOption('1회분 (100g)', 100),
    PortionOption('보통 (150g)', 150),
    PortionOption('많이 (200g)', 200),
  ];
  static const _fallbackMl = [
    PortionOption('소 (150ml)', 150),
    PortionOption('1컵 (200ml)', 200),
    PortionOption('큰 컵 (350ml)', 350),
    PortionOption('대용량 (500ml)', 500),
  ];

  /// 음식 이름에 맞는 단위 목록 반환
  /// 순서: kPortionMapFood → kPortionMapDrinks → usesMilliliters fallback
  static List<PortionOption> getPortions(String foodName) {
    final lower = foodName.toLowerCase();
    for (final entry in kPortionMapFood.entries) {
      if (entry.key.split('|').any(lower.contains)) return entry.value;
    }
    for (final entry in kPortionMapDrinks.entries) {
      if (entry.key.split('|').any(lower.contains)) return entry.value;
    }
    return inputProfileFor(foodName).usesMilliliters ? _fallbackMl : _fallbackGram;
  }

  static bool usesMilliliters(String foodName) =>
      inputProfileFor(foodName).usesMilliliters;

  static bool usesPieceCount(String foodName) {
    final l = foodName.toLowerCase();
    return l.contains('계란 후라이') || l.contains('계란후라이') ||
        l.contains('달걀 후라이') || l.contains('달걀후라이') ||
        l.contains('후라이드 에그') || l.contains('후라이드에그') ||
        l.contains('fried egg');
  }

  static double gramsPerPiece(String foodName) => _defaultEggPieceGrams;

  static FoodInputProfile inputProfileFor(String foodName) =>
      FoodInputClassifier.inputProfileFor(foodName);
}
