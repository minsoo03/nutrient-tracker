import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';

/// 원형 프로그레스 + 수치 표시 위젯
class NutrientCircle extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final double size;
  final bool isMin; // true=목표 이상(식이섬유), false=최대 이하
  final IconData? icon;

  const NutrientCircle({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.size,
    required this.isMin,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final activeColor = _resolveProgressColor(progress);
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
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Icon(icon, size: 12, color: activeColor),
                    ),
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
    if (unit == 'pt') return current.toStringAsFixed(0);
    return current >= 10
        ? current.toStringAsFixed(0)
        : current.toStringAsFixed(1);
  }

  Color _resolveProgressColor(double progress) {
    if (isMin) {
      if (progress >= 1.0) return AppColors.primary;
      if (progress >= 0.7) return Colors.green;
      if (progress >= 0.4) return AppColors.warning;
      return AppColors.error;
    }
    if (progress >= 0.9) return AppColors.error;
    if (progress >= 0.7) return AppColors.warning;
    if (progress >= 0.35) return Colors.green;
    return const Color(0xFF1E88E5);
  }
}
