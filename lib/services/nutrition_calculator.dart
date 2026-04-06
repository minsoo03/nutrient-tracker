import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/services/medicine_service.dart';

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

class NutritionCalculator {
  static int recommendedProteinTarget({
    required double weightKg,
    required HealthGoal goal,
    required bool hasKidneyDisease,
    required bool hasLiverDisease,
  }) {
    double gramsPerKg = switch (goal) {
      HealthGoal.muscle => 1.4,
      HealthGoal.diet => 1.0,
      HealthGoal.medical => 0.8,
      _ => 1.0,
    };

    if (hasKidneyDisease) {
      gramsPerKg = 0.8;
    } else if (hasLiverDisease) {
      gramsPerKg = gramsPerKg.clamp(0.8, 1.0);
    }

    return (weightKg * gramsPerKg).round();
  }

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

    int proteinG = recommendedProteinTarget(
      weightKg: weightKg,
      goal: goal,
      hasKidneyDisease: hasKidneyDisease,
      hasLiverDisease: hasLiverDisease,
    );
    int carbsG   = (calories * cRatio / 4).round();
    int fatG     = (calories * fRatio / 9).round();
    int sodiumMg = 2300;

    // 질환 보정
    if (hasKidneyDisease) {
      sodiumMg = 1500;
    }

    return NutritionTargets(
      calories: calories.round(),
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      sodiumMg: sodiumMg,
      caffeineMax: goal == HealthGoal.medical ? 200 : 400,
      sugarMax: 100,
      fiberMin: gender == Gender.male ? 38 : 25,
    );
  }

  static double estimateLiverLoad({
    required DailyLogModel log,
    required NutritionTargets targets,
    List<String> medications = const [],
    bool hasLiverDisease = false,
    bool hasKidneyDisease = false,
  }) {
    final sugarScore = ((log.totalSugarG / targets.sugarMax) * 35).clamp(0.0, 35.0);
    final fatScore = ((log.totalFatG / targets.fatG) * 25).clamp(0.0, 25.0);
    final caffeineScore =
        ((log.totalCaffeineMg / targets.caffeineMax) * 15).clamp(0.0, 15.0);
    final calorieScore =
        ((log.totalCalories / targets.calories) * 15).clamp(0.0, 15.0);
    final alcoholScore = (log.totalAlcoholG * 2).clamp(0.0, 10.0);
    final proteinOverRatio =
        ((log.totalProteinG - targets.proteinG) / targets.proteinG).clamp(0.0, 1.0);
    final proteinScore = (proteinOverRatio * 8).clamp(0.0, 8.0);

    final riskProfiles = MedicineService.getRiskProfiles(medications);
    final medicationBaseScore = riskProfiles.fold<double>(
      0,
      (sum, profile) => sum + profile.liverWeight,
    ).clamp(0.0, 20.0);
    final medicationProteinScore = riskProfiles
        .where((profile) => profile.sensitiveToProtein)
        .fold<double>(0, (sum, _) => sum + proteinScore * 0.75)
        .clamp(0.0, 12.0);
    final medicationAlcoholScore = riskProfiles
        .where((profile) => profile.sensitiveToAlcohol)
        .fold<double>(0, (sum, _) => sum + (log.totalAlcoholG / 4))
        .clamp(0.0, 10.0);
    final medicationCaffeineScore = riskProfiles
        .where((profile) => profile.sensitiveToCaffeine)
        .fold<double>(0, (sum, _) => sum + (log.totalCaffeineMg / 120))
        .clamp(0.0, 5.0);
    final diseaseScore = (hasLiverDisease ? 8.0 : 0.0) + (hasKidneyDisease ? 4.0 : 0.0);

    return (sugarScore +
            fatScore +
            caffeineScore +
            calorieScore +
            alcoholScore +
            proteinScore +
            medicationBaseScore +
            medicationProteinScore +
            medicationAlcoholScore +
            medicationCaffeineScore +
            diseaseScore)
        .clamp(0.0, 100.0);
  }
}
