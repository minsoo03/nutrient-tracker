import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/nutrient_circle.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';

export 'nutrient_circle.dart' show NutrientCircle;

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
            NutrientCircle(
                label: '탄수화물', current: log.totalCarbsG,
                target: carbsTarget.toDouble(), unit: 'g',
                color: Colors.orange, size: 90, isMin: false),
            NutrientCircle(
                label: '단백질', current: log.totalProteinG,
                target: proteinTarget.toDouble(), unit: 'g',
                color: const Color(0xFF1976D2), size: 90, isMin: false),
            NutrientCircle(
                label: '지방', current: log.totalFatG,
                target: fatTarget.toDouble(), unit: 'g',
                color: const Color(0xFFE91E63), size: 90, isMin: false),
          ],
        ),
      ),
    );
  }
}

// ── 카페인·나트륨·당류·식이섬유·신장·간 6개 원형 ─────────────────────
class NutrientRow extends StatelessWidget {
  final DailyLogModel log;
  final int caffeineMax;
  final int sodiumMax;
  final int sugarMax;
  final int fiberMin;
  final double liverLoad;
  final double kidneyLoad;

  const NutrientRow({
    super.key,
    required this.log,
    required this.caffeineMax,
    required this.sodiumMax,
    required this.sugarMax,
    required this.fiberMin,
    required this.liverLoad,
    required this.kidneyLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Row(
              children: [
                NutrientCircle(
                    label: '카페인', current: log.totalCaffeineMg,
                    target: caffeineMax.toDouble(), unit: 'mg',
                    color: AppColors.caffeine, size: 72, isMin: false),
                NutrientCircle(
                    label: '나트륨', current: log.totalSodiumMg,
                    target: sodiumMax.toDouble(), unit: 'mg',
                    color: AppColors.warning, size: 72, isMin: false),
                NutrientCircle(
                    label: '당류', current: log.totalSugarG,
                    target: sugarMax.toDouble(), unit: 'g',
                    color: Colors.deepOrange, size: 72, isMin: false),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                NutrientCircle(
                    label: '식이섬유', current: log.totalFiberG,
                    target: fiberMin.toDouble(), unit: 'g',
                    color: Colors.teal, size: 72, isMin: true),
                NutrientCircle(
                    label: '신장 무리 수치', current: kidneyLoad,
                    target: 100, unit: 'pt',
                    color: AppColors.kidney, size: 72, isMin: false,
                    icon: Icons.water_drop_outlined),
                NutrientCircle(
                    label: '간 무리 수치', current: liverLoad,
                    target: 100, unit: 'pt',
                    color: AppColors.liver, size: 72, isMin: false,
                    icon: Icons.healing_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
