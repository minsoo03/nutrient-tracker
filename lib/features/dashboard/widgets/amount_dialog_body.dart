import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/meal_companion_data.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/meal_companion_widgets.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/utils/portion_helper.dart';

/// 섭취량 입력 다이얼로그의 본문 위젯
class AmountDialogBody extends StatelessWidget {
  final FoodModel food;
  final List<PortionOption> portions;
  final FoodInputProfile inputProfile;
  final bool usesMl;
  final bool usesPiece;
  final bool isCustom;
  final double? selectedGrams;
  final bool isZeroDrink;
  final String mealType;
  final MealCompanionOption selectedRice;
  final MealCompanionOption selectedSideDish;
  final TextEditingController customCtrl;
  final TextEditingController caffeineCtrl;
  final TextEditingController sugarCtrl;
  final TextEditingController customRiceCtrl;
  final ValueChanged<bool> onIsCustomChanged;
  final ValueChanged<double> onSelectedGramsChanged;
  final ValueChanged<bool> onZeroDrinkChanged;
  final ValueChanged<String> onMealTypeChanged;
  final ValueChanged<MealCompanionOption> onRiceChanged;
  final ValueChanged<MealCompanionOption> onSideDishChanged;

  const AmountDialogBody({
    super.key,
    required this.food,
    required this.portions,
    required this.inputProfile,
    required this.usesMl,
    required this.usesPiece,
    required this.isCustom,
    required this.selectedGrams,
    required this.isZeroDrink,
    required this.mealType,
    required this.selectedRice,
    required this.selectedSideDish,
    required this.customCtrl,
    required this.caffeineCtrl,
    required this.sugarCtrl,
    required this.customRiceCtrl,
    required this.onIsCustomChanged,
    required this.onSelectedGramsChanged,
    required this.onZeroDrinkChanged,
    required this.onMealTypeChanged,
    required this.onRiceChanged,
    required this.onSideDishChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('얼마나 드셨나요?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (portions.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...portions.map((p) => ChoiceChip(
                    label: Text(p.label, style: const TextStyle(fontSize: 12)),
                    selected: !isCustom && selectedGrams == p.grams,
                    onSelected: (_) => onSelectedGramsChanged(p.grams),
                  )),
              ChoiceChip(
                label: const Text('직접 입력', style: TextStyle(fontSize: 12)),
                selected: isCustom,
                onSelected: (v) => onIsCustomChanged(true),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (isCustom)
          NumericInputField(
            controller: customCtrl,
            autofocus: portions.isEmpty,
            labelText: '직접 입력',
            suffixText: usesMl ? 'ml' : (usesPiece ? '개' : 'g'),
          ),
        if (inputProfile.supportsZeroToggle) ...[
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isZeroDrink,
            title: const Text('제로 음료'),
            subtitle: const Text('체크하면 당류를 0g으로 계산합니다.',
                style: TextStyle(fontSize: 11)),
            onChanged: onZeroDrinkChanged,
          ),
        ],
        if (inputProfile.supportsSugarInput && !isZeroDrink) ...[
          const SizedBox(height: 8),
          NumericInputField(
            controller: sugarCtrl,
            labelText: '당 함량',
            hintText: '비워두면 평균값 사용',
            suffixText: 'g',
            helperText: '직접 입력 시 오늘 당류 수치를 이 값으로 계산합니다.',
          ),
        ],
        if (inputProfile.supportsCaffeineInput || food.per100g.caffeineMg > 0) ...[
          const SizedBox(height: 16),
          const Text('카페인 함량',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          NumericInputField(
            controller: caffeineCtrl,
            labelText: '직접 입력',
            hintText: '비워두면 평균값 사용',
            suffixText: 'mg',
          ),
        ],
        if (inputProfile.supportsMealCompanions) ...[
          const SizedBox(height: 16),
          CompanionPicker(
            selectedRice: selectedRice,
            selectedSideDish: selectedSideDish,
            customRiceCtrl: customRiceCtrl,
            onRiceChanged: onRiceChanged,
            onSideDishChanged: onSideDishChanged,
          ),
        ],
        const SizedBox(height: 16),
        const Text('식사 구분',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        MealChips(selected: mealType, onChanged: onMealTypeChanged),
      ],
    );
  }
}

/// 밥/반찬 선택 위젯
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
                    label:
                        Text(opt.label, style: const TextStyle(fontSize: 12)),
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
                    label:
                        Text(opt.label, style: const TextStyle(fontSize: 12)),
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
