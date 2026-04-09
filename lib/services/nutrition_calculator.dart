import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/services/health_load_calculator.dart';
import 'package:nutrient_tracker/services/nutrition_targets.dart';

export 'package:nutrient_tracker/services/health_load_calculator.dart'
    show HealthLoadCalculator;
export 'package:nutrient_tracker/services/nutrition_targets.dart'
    show NutritionTargets;

class NutritionCalculator {
  static NutritionTargets fromUserProfile(UserModel profile) {
    return calculate(
      age: profile.age,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      goal: profile.goal,
      hasKidneyDisease: profile.hasKidneyDisease,
      hasLiverDisease: profile.hasLiverDisease,
    );
  }

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
    double bmr = 10 * weightKg + 6.25 * heightCm - 5 * age;
    if (gender == Gender.male) {
      bmr += 5;
    } else if (gender == Gender.female) {
      bmr -= 161;
    } else {
      bmr -= 78;
    }
    final tdee = bmr * 1.375;
    double calories = switch (goal) {
      HealthGoal.muscle => tdee + 300,
      HealthGoal.diet => (tdee - 500).clamp(
          gender == Gender.female ? 1200.0 : 1500.0, double.infinity),
      _ => tdee,
    };
    final (cRatio, _, fRatio) = switch (goal) {
      HealthGoal.muscle  => (0.45, 0.30, 0.25),
      HealthGoal.diet    => (0.40, 0.35, 0.25),
      HealthGoal.medical => (0.55, 0.20, 0.25),
      _                  => (0.50, 0.25, 0.25),
    };
    int proteinG = recommendedProteinTarget(
      weightKg: weightKg,
      goal: goal,
      hasKidneyDisease: hasKidneyDisease,
      hasLiverDisease: hasLiverDisease,
    );
    int carbsG   = (calories * cRatio / 4).round();
    int fatG     = (calories * fRatio / 9).round();
    int sodiumMg = hasKidneyDisease ? 1500 : 2300;

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

  /// 하위 호환 — HealthLoadCalculator로 위임
  static double estimateLiverLoad({
    required DailyLogModel log,
    required NutritionTargets targets,
    List<String> medications = const [],
    bool hasLiverDisease = false,
    bool hasKidneyDisease = false,
  }) =>
      HealthLoadCalculator.estimateLiverLoad(
        log: log,
        targets: targets,
        medications: medications,
        hasLiverDisease: hasLiverDisease,
        hasKidneyDisease: hasKidneyDisease,
      );

  static double estimateKidneyLoad({
    required DailyLogModel log,
    required NutritionTargets targets,
    List<String> medications = const [],
    bool hasKidneyDisease = false,
    bool hasLiverDisease = false,
  }) =>
      HealthLoadCalculator.estimateKidneyLoad(
        log: log,
        targets: targets,
        medications: medications,
        hasKidneyDisease: hasKidneyDisease,
        hasLiverDisease: hasLiverDisease,
      );
}
