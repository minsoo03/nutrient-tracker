import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/meal_companion_data.dart';

class CompanionSummary extends StatelessWidget {
  final MealCompanionOption rice;
  final MealCompanionOption sideDish;

  const CompanionSummary({
    super.key,
    required this.rice,
    required this.sideDish,
  });

  @override
  Widget build(BuildContext context) {
    final nutrition = rice.nutrition.plus(sideDish.nutrition);
    if (nutrition.calories == 0) {
      return Text(
        '메인 음식만 계산합니다.',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      );
    }
    return Text(
      '추가 반영: ${nutrition.calories.toStringAsFixed(0)} kcal · '
      '탄 ${nutrition.carbsG.toStringAsFixed(1)}g · '
      '단 ${nutrition.proteinG.toStringAsFixed(1)}g · '
      '지 ${nutrition.fatG.toStringAsFixed(1)}g',
      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
    );
  }
}

class MealChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const MealChips({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const types = [
      ('breakfast', '아침'), ('lunch', '점심'),
      ('dinner', '저녁'), ('snack', '간식'),
    ];
    return Wrap(
      spacing: 6,
      children: types.map((t) {
        final (value, label) = t;
        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: selected == value,
          onSelected: (_) => onChanged(value),
        );
      }).toList(),
    );
  }
}
