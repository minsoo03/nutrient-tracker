/// 하루 영양소 목표치 모음
class NutritionTargets {
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int sodiumMg;
  final int caffeineMax; // mg
  final int sugarMax;   // g
  final int fiberMin;   // g

  const NutritionTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.sodiumMg,
    required this.caffeineMax,
    required this.sugarMax,
    required this.fiberMin,
  });

  static const defaultTargets = NutritionTargets(
    calories: 2000,
    proteinG: 60,
    carbsG: 250,
    fatG: 65,
    sodiumMg: 2300,
    caffeineMax: 400,
    sugarMax: 100,
    fiberMin: 25,
  );
}
