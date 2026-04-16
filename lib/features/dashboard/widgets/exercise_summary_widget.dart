import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';

/// 운동 칼로리 요약 패널 (섭취 / 운동 소모)
class ExerciseSummary extends StatelessWidget {
  final double consumedCalories;
  final double burnedCalories;

  const ExerciseSummary({
    super.key,
    required this.consumedCalories,
    required this.burnedCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kidney.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.kidney.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricPill(
            icon: Icons.restaurant_rounded,
            label: '섭취',
            value: '${consumedCalories.toStringAsFixed(0)} kcal',
            color: AppColors.primary,
          ),
          _MetricPill(
            icon: Icons.directions_run_rounded,
            label: '운동 소모',
            value: '${burnedCalories.toStringAsFixed(0)} kcal',
            color: AppColors.kidney,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
