import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/exercise_log_section.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/food_log_section.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/nutrition_widgets.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

class DashboardDailyView extends StatelessWidget {
  final DailyLogModel log;
  final NutritionTargets targets;
  final UserModel? userProfile;
  final String uid;
  final String date;
  final String dateLabel;
  final NutritionService nutritionService;
  final bool showExercise;

  const DashboardDailyView({
    super.key,
    required this.log,
    required this.targets,
    required this.userProfile,
    required this.uid,
    required this.date,
    required this.dateLabel,
    required this.nutritionService,
    this.showExercise = false,
  });

  @override
  Widget build(BuildContext context) {
    final liverLoad = NutritionCalculator.estimateLiverLoad(
      log: log,
      targets: targets,
      medications: userProfile?.medications ?? const [],
      hasLiverDisease: userProfile?.hasLiverDisease ?? false,
      hasKidneyDisease: userProfile?.hasKidneyDisease ?? false,
    );
    final kidneyLoad = NutritionCalculator.estimateKidneyLoad(
      log: log,
      targets: targets,
      medications: userProfile?.medications ?? const [],
      hasKidneyDisease: userProfile?.hasKidneyDisease ?? false,
      hasLiverDisease: userProfile?.hasLiverDisease ?? false,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          CaloriesCard(
            log: log,
            target: targets.calories,
            showExercise: showExercise,
          ),
          const SizedBox(height: 10),
          const _SectionLabel('주요 영양소'),
          MacrosRow(
            log: log,
            carbsTarget: targets.carbsG,
            proteinTarget: targets.proteinG,
            fatTarget: targets.fatG,
          ),
          const SizedBox(height: 10),
          const _SectionLabel('건강 지표'),
          NutrientRow(
            log: log,
            caffeineMax: targets.caffeineMax,
            sodiumMax: targets.sodiumMg,
            sugarMax: targets.sugarMax,
            fiberMin: targets.fiberMin,
            liverLoad: liverLoad,
            kidneyLoad: kidneyLoad,
          ),
          const SizedBox(height: 16),
          const _SectionLabel('식단 기록'),
          FoodLogSection(uid: uid, date: date, nutritionService: nutritionService),
          if (showExercise) ...[
            const SizedBox(height: 16),
            const _SectionLabel('운동 기록'),
            ExerciseLogSection(
              uid: uid,
              date: date,
              nutritionService: nutritionService,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }
}
