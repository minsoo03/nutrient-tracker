import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';

export 'nutrient_charts.dart'; // MacrosRow, NutrientRow, NutrientCircle 재export

class CaloriesCard extends StatelessWidget {
  final DailyLogModel log;
  final int target;
  final bool showExercise;

  const CaloriesCard({
    super.key,
    required this.log,
    required this.target,
    this.showExercise = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayedCalories = showExercise
        ? (log.totalCalories - log.totalExerciseCalories).clamp(0.0, double.infinity)
        : log.totalCalories;
    final progress = (displayedCalories / target).clamp(0.0, 1.0);
    final remaining = (target - displayedCalories).round();
    final isOver = remaining < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    color: isOver ? AppColors.error : AppColors.primary,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayedCalories.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text('kcal',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  label: showExercise ? '섭취 칼로리' : '목표',
                  value: showExercise
                      ? '${log.totalCalories.toStringAsFixed(0)} kcal'
                      : '$target kcal',
                ),
                _Stat(
                  label: showExercise
                      ? '운동 소모'
                      : (isOver ? '초과' : '남은 칼로리'),
                  value: showExercise
                      ? '${log.totalExerciseCalories.toStringAsFixed(0)} kcal'
                      : '${remaining.abs()} kcal',
                  color: showExercise
                      ? AppColors.secondary
                      : (isOver ? AppColors.error : AppColors.primary),
                ),
              ],
            ),
            if (showExercise) ...[
              const SizedBox(height: 10),
              _Stat(
                  label: isOver ? '순칼로리 초과' : '순칼로리 남음',
                  value: '${remaining.abs()} kcal',
                  color: isOver ? AppColors.error : AppColors.primary,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
