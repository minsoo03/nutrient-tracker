import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';

export 'nutrient_charts.dart'; // MacrosRow, NutrientRow, NutrientCircle 재export

class CaloriesCard extends StatelessWidget {
  final DailyLogModel log;
  final int target;

  const CaloriesCard({super.key, required this.log, required this.target});

  @override
  Widget build(BuildContext context) {
    final progress = (log.totalCalories / target).clamp(0.0, 1.0);
    final remaining = (target - log.totalCalories).round();
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
                      log.totalCalories.toStringAsFixed(0),
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
                _Stat(label: '목표', value: '$target kcal'),
                _Stat(
                  label: isOver ? '초과' : '남은 칼로리',
                  value: '${remaining.abs()} kcal',
                  color: isOver ? AppColors.error : AppColors.primary,
                ),
              ],
            ),
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
