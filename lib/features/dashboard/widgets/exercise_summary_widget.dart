import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';

/// 운동 칼로리 요약 패널 (섭취 / 운동 소모 / 순칼로리)
class ExerciseSummary extends StatelessWidget {
  final double consumedCalories;
  final double burnedCalories;
  final double netCalories;
  final double targetCalories;

  const ExerciseSummary({
    super.key,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.netCalories,
    required this.targetCalories,
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '섭취에서 운동 소모를 뺀 순칼로리 기준입니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                value: '-${burnedCalories.toStringAsFixed(0)} kcal',
                color: AppColors.kidney,
              ),
              _MetricPill(
                icon: Icons.calculate_rounded,
                label: '순칼로리',
                value: '${netCalories.toStringAsFixed(0)} kcal',
                color: AppColors.warning,
              ),
            ],
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
