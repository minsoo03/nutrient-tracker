import 'package:nutrient_tracker/features/auth/models/user_model.dart';

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
    sugarMax: 50,
    fiberMin: 25,
  );
}

class NutritionCalculator {
  /// Mifflin-St Jeor BMR + TDEE + 목표/질환 보정
  static NutritionTargets calculate({
    required int age,
    required Gender gender,
    required double heightCm,
    required double weightKg,
    required HealthGoal goal,
    required bool hasKidneyDisease,
    required bool hasLiverDisease,
  }) {
    // BMR
    double bmr = 10 * weightKg + 6.25 * heightCm - 5 * age;
    if (gender == Gender.male) {
      bmr += 5;
    } else if (gender == Gender.female) {
      bmr -= 161;
    } else {
      bmr -= 78; // 평균
    }

    // TDEE (가벼운 활동 기준 ×1.375)
    final tdee = bmr * 1.375;

    // 목표별 칼로리 조정
    double calories = switch (goal) {
      HealthGoal.muscle => tdee + 300,
      HealthGoal.diet => (tdee - 500).clamp(
          gender == Gender.female ? 1200.0 : 1500.0, double.infinity),
      _ => tdee,
    };

    // 목표별 매크로 비율 (탄수화물%, 단백질%, 지방%)
    final (cRatio, pRatio, fRatio) = switch (goal) {
      HealthGoal.muscle => (0.45, 0.30, 0.25),
      HealthGoal.diet   => (0.40, 0.35, 0.25),
      HealthGoal.medical => (0.55, 0.20, 0.25),
      _ /* health */    => (0.50, 0.25, 0.25),
    };

    int proteinG = (calories * pRatio / 4).round();
    int carbsG   = (calories * cRatio / 4).round();
    int fatG     = (calories * fRatio / 9).round();
    int sodiumMg = 2300;

    // 질환 보정
    if (hasKidneyDisease) {
      proteinG = proteinG.clamp(0, (0.8 * weightKg).round());
      sodiumMg = 1500;
    }
    if (hasLiverDisease) {
      proteinG = proteinG.clamp(0, (1.0 * weightKg).round());
    }

    return NutritionTargets(
      calories: calories.round(),
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      sodiumMg: sodiumMg,
      caffeineMax: goal == HealthGoal.medical ? 200 : 400,
      sugarMax: goal == HealthGoal.diet ? 25 : 50,
      fiberMin: gender == Gender.male ? 38 : 25,
    );
  }
}
