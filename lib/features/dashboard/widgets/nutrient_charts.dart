import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';

// ── 탄단지 3개 원형 차트 ──────────────────────────────────────────
class MacrosRow extends StatelessWidget {
  final DailyLogModel log;
  final int carbsTarget;
  final int proteinTarget;
  final int fatTarget;

  const MacrosRow({
    super.key,
    required this.log,
    required this.carbsTarget,
    required this.proteinTarget,
    required this.fatTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            NutrientCircle(label: '탄수화물', current: log.totalCarbsG,
                target: carbsTarget.toDouble(), unit: 'g',
                color: Colors.orange, size: 90, isMin: false),
            NutrientCircle(label: '단백질', current: log.totalProteinG,
                target: proteinTarget.toDouble(), unit: 'g',
                color: const Color(0xFF1976D2), size: 90, isMin: false),
            NutrientCircle(label: '지방', current: log.totalFatG,
                target: fatTarget.toDouble(), unit: 'g',
                color: const Color(0xFFE91E63), size: 90, isMin: false),
          ],
        ),
      ),
    );
  }
}

// ── 카페인·나트륨·당류·식이섬유 4개 원형 ─────────────────────────────
class NutrientRow extends StatelessWidget {
  final DailyLogModel log;
  final int caffeineMax;
  final int sodiumMax;
  final int sugarMax;
  final int fiberMin;

  const NutrientRow({
    super.key,
    required this.log,
    required this.caffeineMax,
    required this.sodiumMax,
    required this.sugarMax,
    required this.fiberMin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            NutrientCircle(label: '카페인', current: log.totalCaffeineMg,
                target: caffeineMax.toDouble(), unit: 'mg',
                color: AppColors.caffeine, size: 72, isMin: false),
            NutrientCircle(label: '나트륨', current: log.totalSodiumMg,
                target: sodiumMax.toDouble(), unit: 'mg',
                color: AppColors.warning, size: 72, isMin: false),
            NutrientCircle(label: '당류', current: log.totalSugarG,
                target: sugarMax.toDouble(), unit: 'g',
                color: Colors.deepOrange, size: 72, isMin: false),
            NutrientCircle(label: '식이섬유', current: log.totalFiberG,
                target: fiberMin.toDouble(), unit: 'g',
                color: Colors.teal, size: 72, isMin: true),
          ],
        ),
      ),
    );
  }
}

// ── 공용 원형 차트 위젯 ───────────────────────────────────────────
class NutrientCircle extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final double size;
  final bool isMin; // true=목표 이상(식이섬유), false=최대 이하

  const NutrientCircle({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.size,
    required this.isMin,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final isWarning = isMin ? current < target * 0.5 : current > target;
    final activeColor = isWarning ? AppColors.error : color;
    final strokeWidth = size >= 90 ? 8.0 : 7.0;
    final valueFontSize = size >= 90 ? 16.0 : 13.0;

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  color: activeColor,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _displayValue(),
                    style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: activeColor),
                  ),
                  Text(unit,
                      style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Text(
            isMin
                ? '목표 ${target.toStringAsFixed(0)}$unit↑'
                : '/ ${target.toStringAsFixed(0)}$unit',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _displayValue() {
    if (current >= 1000 && unit == 'mg') {
      return '${(current / 1000).toStringAsFixed(1)}k';
    }
    return current >= 10
        ? current.toStringAsFixed(0)
        : current.toStringAsFixed(1);
  }
}
