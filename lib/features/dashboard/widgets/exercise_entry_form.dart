import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/services/exercise_calculator.dart';

/// 운동 추가 다이얼로그의 폼 내용 위젯
class ExerciseEntryForm extends StatelessWidget {
  static const String customExerciseLabel = '직접 입력';

  final String selectedExercise;
  final bool isCustomExercise;
  final TextEditingController customNameCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController caloriesCtrl;
  final double weightKg;
  final ExercisePreset? selectedPreset;
  final bool isLoading;
  final ValueChanged<String?> onExerciseChanged;
  final ValueChanged<String> onDurationChanged;
  final ValueChanged<String> onCaloriesManuallyEdited;

  const ExerciseEntryForm({
    super.key,
    required this.selectedExercise,
    required this.isCustomExercise,
    required this.customNameCtrl,
    required this.durationCtrl,
    required this.caloriesCtrl,
    required this.weightKg,
    required this.selectedPreset,
    required this.isLoading,
    required this.onExerciseChanged,
    required this.onDurationChanged,
    required this.onCaloriesManuallyEdited,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedExercise,
            items: [
              ...ExerciseCalculator.presets.map(
                (preset) => DropdownMenuItem(
                  value: preset.name,
                  child: Text(preset.name),
                ),
              ),
              const DropdownMenuItem(
                value: customExerciseLabel,
                child: Text(customExerciseLabel),
              ),
            ],
            onChanged: isLoading ? null : onExerciseChanged,
            decoration: const InputDecoration(
              labelText: '운동 종류',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          if (isCustomExercise) ...[
            TextField(
              controller: customNameCtrl,
              decoration: const InputDecoration(
                labelText: '운동명',
                hintText: '예: 배드민턴',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
          ],
          NumericInputField(
            controller: durationCtrl,
            labelText: '운동 시간',
            suffixText: '분',
            allowDecimal: false,
            onChanged: onDurationChanged,
          ),
          const SizedBox(height: 10),
          NumericInputField(
            controller: caloriesCtrl,
            labelText: '소모 칼로리',
            suffixText: 'kcal',
            helperText: selectedPreset == null
                ? '직접 입력 운동은 칼로리를 직접 넣어주세요.'
                : '체중 ${weightKg.toStringAsFixed(0)}kg 기준 추정치입니다. 수정 가능합니다.',
            onChanged: onCaloriesManuallyEdited,
          ),
        ],
      ),
    );
  }
}
