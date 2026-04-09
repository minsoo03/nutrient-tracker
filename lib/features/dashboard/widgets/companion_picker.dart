import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/meal_companion_data.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/meal_companion_widgets.dart';

/// 밥 양 + 반찬 선택 위젯
class CompanionPicker extends StatelessWidget {
  final MealCompanionOption selectedRice;
  final MealCompanionOption selectedSideDish;
  final TextEditingController customRiceCtrl;
  final ValueChanged<MealCompanionOption> onRiceChanged;
  final ValueChanged<MealCompanionOption> onSideDishChanged;

  const CompanionPicker({
    super.key,
    required this.selectedRice,
    required this.selectedSideDish,
    required this.customRiceCtrl,
    required this.onRiceChanged,
    required this.onSideDishChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('밥 양',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: riceOptions
              .map((opt) => ChoiceChip(
                    label: Text(opt.label,
                        style: const TextStyle(fontSize: 12)),
                    selected: selectedRice.key == opt.key,
                    onSelected: (sel) {
                      if (sel) onRiceChanged(opt);
                    },
                  ))
              .toList(),
        ),
        if (selectedRice.key == 'custom') ...[
          const SizedBox(height: 8),
          NumericInputField(
            controller: customRiceCtrl,
            labelText: '밥 공기 수',
            hintText: '예: 2.5',
            suffixText: '공기',
          ),
        ],
        const SizedBox(height: 16),
        const Text('반찬 포함',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: sideDishOptions
              .map((opt) => ChoiceChip(
                    label: Text(opt.label,
                        style: const TextStyle(fontSize: 12)),
                    selected: selectedSideDish.key == opt.key,
                    onSelected: (sel) {
                      if (sel) onSideDishChanged(opt);
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        CompanionSummary(
          rice: resolvedRiceOption(selectedRice, customRiceCtrl.text),
          sideDish: selectedSideDish,
        ),
      ],
    );
  }
}
