import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/services/medicine_service.dart';
import 'package:nutrient_tracker/services/nutrition_targets.dart';

/// 간/신장 부하 점수 계산 (0~100)
class HealthLoadCalculator {
  static double estimateLiverLoad({
    required DailyLogModel log,
    required NutritionTargets targets,
    List<String> medications = const [],
    bool hasLiverDisease = false,
    bool hasKidneyDisease = false,
  }) {
    final sugarScore =
        ((log.totalSugarG / targets.sugarMax) * 35).clamp(0.0, 35.0);
    final fatScore =
        ((log.totalFatG / targets.fatG) * 25).clamp(0.0, 25.0);
    final caffeineScore =
        ((log.totalCaffeineMg / targets.caffeineMax) * 15).clamp(0.0, 15.0);
    final calorieScore =
        ((log.totalCalories / targets.calories) * 15).clamp(0.0, 15.0);
    final alcoholScore = (log.totalAlcoholG * 2).clamp(0.0, 10.0);
    final proteinOverRatio =
        ((log.totalProteinG - targets.proteinG) / targets.proteinG)
            .clamp(0.0, 1.0);
    final proteinScore = (proteinOverRatio * 8).clamp(0.0, 8.0);

    final riskProfiles = MedicineService.getRiskProfiles(medications);
    final medicationBaseScore = riskProfiles
        .fold<double>(0, (sum, p) => sum + p.liverWeight)
        .clamp(0.0, 20.0);
    final medicationProteinScore = riskProfiles
        .where((p) => p.sensitiveToProtein)
        .fold<double>(0, (sum, _) => sum + proteinScore * 0.75)
        .clamp(0.0, 12.0);
    final medicationAlcoholScore = riskProfiles
        .where((p) => p.sensitiveToAlcohol)
        .fold<double>(0, (sum, _) => sum + (log.totalAlcoholG / 4))
        .clamp(0.0, 10.0);
    final medicationCaffeineScore = riskProfiles
        .where((p) => p.sensitiveToCaffeine)
        .fold<double>(0, (sum, _) => sum + (log.totalCaffeineMg / 120))
        .clamp(0.0, 5.0);
    final diseaseScore =
        (hasLiverDisease ? 8.0 : 0.0) + (hasKidneyDisease ? 4.0 : 0.0);

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

  static double estimateKidneyLoad({
    required DailyLogModel log,
    required NutritionTargets targets,
    List<String> medications = const [],
    bool hasKidneyDisease = false,
    bool hasLiverDisease = false,
  }) {
    final sodiumScore =
        ((log.totalSodiumMg / targets.sodiumMg) * 30).clamp(0.0, 30.0);
    final proteinOverRatio =
        ((log.totalProteinG - targets.proteinG) / targets.proteinG)
            .clamp(0.0, 1.0);
    final proteinScore = (proteinOverRatio * 30).clamp(0.0, 30.0);
    final caffeineScore =
        ((log.totalCaffeineMg / targets.caffeineMax) * 8).clamp(0.0, 8.0);
    final alcoholScore = (log.totalAlcoholG * 0.5).clamp(0.0, 6.0);

    final riskProfiles = MedicineService.getRiskProfiles(medications);
    final medicationBaseScore = riskProfiles
        .fold<double>(0, (sum, p) => sum + p.kidneyWeight)
        .clamp(0.0, 24.0);
    final medicationProteinScore = riskProfiles
        .where((p) => p.sensitiveToProtein)
        .fold<double>(0, (sum, _) => sum + proteinScore * 0.35)
        .clamp(0.0, 12.0);
    final medicationAlcoholScore = riskProfiles
        .where((p) => p.sensitiveToAlcohol)
        .fold<double>(0, (sum, _) => sum + (log.totalAlcoholG / 6))
        .clamp(0.0, 6.0);
    final medicationCaffeineScore = riskProfiles
        .where((p) => p.sensitiveToCaffeine)
        .fold<double>(0, (sum, _) => sum + (log.totalCaffeineMg / 200))
        .clamp(0.0, 4.0);
    final diseaseScore =
        (hasKidneyDisease ? 10.0 : 0.0) + (hasLiverDisease ? 2.0 : 0.0);

    return (sodiumScore +
            proteinScore +
            caffeineScore +
            alcoholScore +
            medicationBaseScore +
            medicationProteinScore +
            medicationAlcoholScore +
            medicationCaffeineScore +
            diseaseScore)
        .clamp(0.0, 100.0);
  }
}
