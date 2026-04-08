import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';

/// 직접 입력 다이얼로그의 폼 내용 위젯
class ManualFoodEntryForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  final TextEditingController caloriesCtrl;
  final TextEditingController carbsCtrl;
  final TextEditingController proteinCtrl;
  final TextEditingController fatCtrl;
  final TextEditingController sugarCtrl;
  final TextEditingController fiberCtrl;
  final TextEditingController sodiumCtrl;
  final TextEditingController caffeineCtrl;
  final TextEditingController alcoholCtrl;
  final String mealType;
  final ValueChanged<String> onMealTypeChanged;

  const ManualFoodEntryForm({
    super.key,
    required this.nameCtrl,
    required this.amountCtrl,
    required this.caloriesCtrl,
    required this.carbsCtrl,
    required this.proteinCtrl,
    required this.fatCtrl,
    required this.sugarCtrl,
    required this.fiberCtrl,
    required this.sodiumCtrl,
    required this.caffeineCtrl,
    required this.alcoholCtrl,
    required this.mealType,
    required this.onMealTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _textField(nameCtrl, '음식명', TextInputType.text),
          const SizedBox(height: 10),
          NumericInputField(
              controller: amountCtrl, labelText: '섭취량', suffixText: 'g/ml'),
          const SizedBox(height: 10),
          NumericInputField(
              controller: caloriesCtrl, labelText: '칼로리', suffixText: 'kcal'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: NumericInputField(
                      controller: carbsCtrl,
                      labelText: '탄수화물',
                      suffixText: 'g')),
              const SizedBox(width: 8),
              Expanded(
                  child: NumericInputField(
                      controller: proteinCtrl,
                      labelText: '단백질',
                      suffixText: 'g')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: NumericInputField(
                      controller: fatCtrl, labelText: '지방', suffixText: 'g')),
              const SizedBox(width: 8),
              Expanded(
                  child: NumericInputField(
                      controller: sugarCtrl, labelText: '당류', suffixText: 'g')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: NumericInputField(
                      controller: fiberCtrl,
                      labelText: '식이섬유',
                      suffixText: 'g')),
              const SizedBox(width: 8),
              Expanded(
                  child: NumericInputField(
                      controller: sodiumCtrl,
                      labelText: '나트륨',
                      suffixText: 'mg')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: NumericInputField(
                      controller: caffeineCtrl,
                      labelText: '카페인',
                      suffixText: 'mg')),
              const SizedBox(width: 8),
              Expanded(
                  child: NumericInputField(
                      controller: alcoholCtrl,
                      labelText: '알코올',
                      suffixText: 'g')),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('식사 구분',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              _mealChip('breakfast', '아침'),
              _mealChip('lunch', '점심'),
              _mealChip('dinner', '저녁'),
              _mealChip('snack', '간식'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _mealChip(String value, String label) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: mealType == value,
      onSelected: (selected) {
        if (selected) onMealTypeChanged(value);
      },
    );
  }
}
