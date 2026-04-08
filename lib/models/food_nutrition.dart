/// 영양소 수치 (100g 기준 또는 scaled)
class FoodNutrition {
  final double calories;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double sugarG;
  final double fiberG;
  final double sodiumMg;
  final double caffeineMg;
  final double alcoholG;

  const FoodNutrition({
    required this.calories,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.sugarG,
    required this.fiberG,
    required this.sodiumMg,
    required this.caffeineMg,
    this.alcoholG = 0,
  });

  /// 섭취량(g/ml) 기준으로 스케일링
  FoodNutrition scaled(double grams) {
    final ratio = grams / 100.0;
    return FoodNutrition(
      calories: calories * ratio,
      carbsG: carbsG * ratio,
      proteinG: proteinG * ratio,
      fatG: fatG * ratio,
      sugarG: sugarG * ratio,
      fiberG: fiberG * ratio,
      sodiumMg: sodiumMg * ratio,
      caffeineMg: caffeineMg * ratio,
      alcoholG: alcoholG * ratio,
    );
  }

  /// 두 FoodNutrition 더하기 (반찬/밥 추가 칼로리 합산 등)
  FoodNutrition plus(FoodNutrition other) {
    return FoodNutrition(
      calories: calories + other.calories,
      carbsG: carbsG + other.carbsG,
      proteinG: proteinG + other.proteinG,
      fatG: fatG + other.fatG,
      sugarG: sugarG + other.sugarG,
      fiberG: fiberG + other.fiberG,
      sodiumMg: sodiumMg + other.sodiumMg,
      caffeineMg: caffeineMg + other.caffeineMg,
      alcoholG: alcoholG + other.alcoholG,
    );
  }
}
