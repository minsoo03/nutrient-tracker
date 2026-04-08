import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/food_model.dart';

export 'amount_dialog.dart' show showAmountDialog;
export 'meal_companion_data.dart' show MealCompanionOption;

class FoodResultItem extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onTap;

  const FoodResultItem({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = food.per100g;
    final isAveraged = food.variantCount > 1;
    final packageSummary = isAveraged ? null : food.packageCaloriesSummary;
    final basisText = packageSummary == null
        ? (isAveraged ? '100g 평균 기준' : food.displayBasisLabel)
        : '${food.displayBasisLabel} · $packageSummary';

    return ListTile(
      onTap: onTap,
      title: Row(
        children: [
          Expanded(
            child: Text(food.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          if (isAveraged)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${food.variantCount}종 평균',
                  style: TextStyle(fontSize: 10, color: AppColors.primary)),
            ),
        ],
      ),
      subtitle: Text(
        '${n.calories.toStringAsFixed(0)} kcal · 탄 ${n.carbsG.toStringAsFixed(1)}g · '
        '단 ${n.proteinG.toStringAsFixed(1)}g · 지 ${n.fatG.toStringAsFixed(1)}g  ($basisText)',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
      trailing:
          const Icon(Icons.add_circle_outline, color: AppColors.primary),
    );
  }
}
