import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/utils/portion_helper.dart';

class MealCompanionOption {
  final String key;
  final String label;
  final FoodNutrition nutrition;

  const MealCompanionOption({
    required this.key,
    required this.label,
    required this.nutrition,
  });
}

const _noneNutrition = FoodNutrition(
  calories: 0,
  carbsG: 0,
  proteinG: 0,
  fatG: 0,
  sugarG: 0,
  fiberG: 0,
  sodiumMg: 0,
  caffeineMg: 0,
  alcoholG: 0,
);

const _riceOptions = [
  MealCompanionOption(
    key: 'none',
    label: '밥 없음',
    nutrition: _noneNutrition,
  ),
  MealCompanionOption(
    key: 'half',
    label: '반 공기',
    nutrition: FoodNutrition(
      calories: 150,
      carbsG: 33,
      proteinG: 3,
      fatG: 0.4,
      sugarG: 0,
      fiberG: 0.5,
      sodiumMg: 2,
      caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'full',
    label: '한 공기',
    nutrition: FoodNutrition(
      calories: 300,
      carbsG: 66,
      proteinG: 6,
      fatG: 0.8,
      sugarG: 0,
      fiberG: 1,
      sodiumMg: 4,
      caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'double',
    label: '두 공기',
    nutrition: FoodNutrition(
      calories: 600,
      carbsG: 132,
      proteinG: 12,
      fatG: 1.6,
      sugarG: 0,
      fiberG: 2,
      sodiumMg: 8,
      caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'custom',
    label: '직접 입력',
    nutrition: _noneNutrition,
  ),
];

const _sideDishOptions = [
  MealCompanionOption(
    key: 'none',
    label: '반찬 없음',
    nutrition: _noneNutrition,
  ),
  MealCompanionOption(
    key: 'light',
    label: '반찬 조금',
    nutrition: FoodNutrition(
      calories: 80,
      carbsG: 6,
      proteinG: 3,
      fatG: 4,
      sugarG: 2,
      fiberG: 1.5,
      sodiumMg: 220,
      caffeineMg: 0,
    ),
  ),
  MealCompanionOption(
    key: 'normal',
    label: '반찬 보통',
    nutrition: FoodNutrition(
      calories: 160,
      carbsG: 12,
      proteinG: 6,
      fatG: 8,
      sugarG: 3,
      fiberG: 3,
      sodiumMg: 450,
      caffeineMg: 0,
    ),
  ),
];

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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          if (isAveraged)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
    );
  }
}

/// 섭취량 다이얼로그
/// returns
/// (amount, mealType, extraNutrition, companionLabel, caffeineOverrideMg, sugarOverrideG, isZeroDrink)
/// or null
Future<(double, String, FoodNutrition, String?, double?, double?, bool)?> showAmountDialog(
  BuildContext context,
  FoodModel food,
) async {
  final portions = PortionHelper.getPortions(food.name);
  final inputProfile = PortionHelper.inputProfileFor(food.name);
  final usesMilliliters = inputProfile.usesMilliliters;
  final customCtrl = TextEditingController();
  final caffeineCtrl = TextEditingController();
  final sugarCtrl = TextEditingController();
  final isAveraged = food.variantCount > 1;
  final supportsCompanions = inputProfile.supportsMealCompanions;
  final supportsCaffeineInput =
      inputProfile.supportsCaffeineInput || food.per100g.caffeineMg > 0;
  final supportsSugarInput = inputProfile.supportsSugarInput;
  final supportsZeroToggle = inputProfile.supportsZeroToggle;
  final customRiceCtrl = TextEditingController();
  double? selectedGrams = portions.isNotEmpty ? portions.first.grams : null;
  bool isCustom = portions.isEmpty;
  bool isZeroDrink = false;
  String mealType = 'snack';
  var selectedRice = _riceOptions[1];
  var selectedSideDish = _sideDishOptions[1];
  (double, String, FoodNutrition, String?, double?, double?, bool)? result;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(food.name,
                maxLines: 2, style: const TextStyle(fontSize: 15)),
            if (food.variantCount > 1)
              Text('${food.variantCount}종 평균값',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(
              '칼로리 ${food.per100g.calories.toStringAsFixed(0)} kcal · '
              '탄 ${food.per100g.carbsG.toStringAsFixed(1)}g · '
              '단 ${food.per100g.proteinG.toStringAsFixed(1)}g · '
              '지 ${food.per100g.fatG.toStringAsFixed(1)}g',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              isAveraged
                  ? '100g 평균 기준'
                  : food.packageCaloriesSummary == null
                      ? food.displayBasisLabel
                      : '${food.displayBasisLabel} · ${food.packageCaloriesSummary}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
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
                          label: Text(p.label,
                              style: const TextStyle(fontSize: 12)),
                          selected: !isCustom && selectedGrams == p.grams,
                          onSelected: (_) => set(() {
                            isCustom = false;
                            selectedGrams = p.grams;
                            customCtrl.clear();
                          }),
                        )),
                    ChoiceChip(
                      label: const Text('직접 입력',
                          style: TextStyle(fontSize: 12)),
                      selected: isCustom,
                      onSelected: (selected) =>
                          set(() { isCustom = true; selectedGrams = null; }),
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
                  suffixText: usesMilliliters ? 'ml' : 'g',
                ),
              if (supportsZeroToggle) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isZeroDrink,
                  title: const Text('제로 음료'),
                  subtitle: const Text(
                    '체크하면 당류를 0g으로 계산합니다.',
                    style: TextStyle(fontSize: 11),
                  ),
                  onChanged: (value) {
                    set(() {
                      isZeroDrink = value;
                      if (value) sugarCtrl.clear();
                    });
                  },
                ),
              ],
              if (supportsSugarInput && !isZeroDrink) ...[
                const SizedBox(height: 8),
                NumericInputField(
                  controller: sugarCtrl,
                  labelText: '당 함량',
                  hintText: '비워두면 평균값 사용',
                  suffixText: 'g',
                  helperText: '직접 입력 시 오늘 당류 수치를 이 값으로 계산합니다.',
                ),
              ],
              if (supportsCaffeineInput) ...[
                const SizedBox(height: 16),
                const Text('카페인 함량',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                NumericInputField(
                  controller: caffeineCtrl,
                  labelText: '직접 입력',
                  hintText: '비워두면 평균값 사용',
                  suffixText: 'mg',
                  helperText: food.per100g.caffeineMg > 0
                      ? '현재 평균 추정치가 적용됩니다.'
                      : '입력하지 않으면 기본 평균값을 사용합니다.',
                ),
              ],
              if (supportsCompanions) ...[
                const SizedBox(height: 16),
                const Text('밥 양',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _riceOptions.map((option) {
                    return ChoiceChip(
                      label: Text(option.label,
                          style: const TextStyle(fontSize: 12)),
                      selected: selectedRice.key == option.key,
                      onSelected: (isSelected) {
                        if (!isSelected) return;
                        set(() {
                          selectedRice = option;
                          if (option.key != 'custom') {
                            customRiceCtrl.clear();
                          }
                        });
                      },
                    );
                  }).toList(),
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
                  children: _sideDishOptions.map((option) {
                    return ChoiceChip(
                      label: Text(option.label,
                          style: const TextStyle(fontSize: 12)),
                      selected: selectedSideDish.key == option.key,
                      onSelected: (isSelected) {
                        if (!isSelected) return;
                        set(() => selectedSideDish = option);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                _CompanionSummary(
                  rice: _resolvedRiceOption(selectedRice, customRiceCtrl.text),
                  sideDish: selectedSideDish,
                ),
              ],
              const SizedBox(height: 16),
              const Text('식사 구분',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _MealChips(
                  selected: mealType,
                  onChanged: (v) => set(() => mealType = v)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              final grams = isCustom
                  ? double.tryParse(customCtrl.text)
                  : selectedGrams;
              if (grams != null && grams > 0) {
                final resolvedRice =
                    _resolvedRiceOption(selectedRice, customRiceCtrl.text);
                final extraNutrition = supportsCompanions
                    ? resolvedRice.nutrition.plus(selectedSideDish.nutrition)
                    : _noneNutrition;
                final companionLabel = supportsCompanions
                    ? _buildCompanionLabel(resolvedRice, selectedSideDish)
                    : null;
                final caffeineOverride = double.tryParse(caffeineCtrl.text);
                final sugarOverride =
                    isZeroDrink ? 0.0 : double.tryParse(sugarCtrl.text);
                result = (
                  grams,
                  mealType,
                  extraNutrition,
                  companionLabel,
                  caffeineOverride,
                  sugarOverride,
                  isZeroDrink,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    ),
  );

  return result;
}

MealCompanionOption _resolvedRiceOption(
  MealCompanionOption selectedRice,
  String customRiceValue,
) {
  if (selectedRice.key != 'custom') return selectedRice;

  final bowls = double.tryParse(customRiceValue.trim()) ?? 0;
  if (bowls <= 0) {
    return const MealCompanionOption(
      key: 'none',
      label: '밥 없음',
      nutrition: _noneNutrition,
    );
  }

  return MealCompanionOption(
    key: 'custom',
    label: '${bowls.toStringAsFixed(bowls % 1 == 0 ? 0 : 1)}공기',
    nutrition: FoodNutrition(
      calories: 300 * bowls,
      carbsG: 66 * bowls,
      proteinG: 6 * bowls,
      fatG: 0.8 * bowls,
      sugarG: 0,
      fiberG: 1 * bowls,
      sodiumMg: 4 * bowls,
      caffeineMg: 0,
    ),
  );
}

String? _buildCompanionLabel(
  MealCompanionOption rice,
  MealCompanionOption sideDish,
) {
  final parts = <String>[];
  if (rice.key != 'none') parts.add(rice.label);
  if (sideDish.key != 'none') parts.add(sideDish.label);
  if (parts.isEmpty) return null;
  return parts.join(' + ');
}

class _CompanionSummary extends StatelessWidget {
  final MealCompanionOption rice;
  final MealCompanionOption sideDish;

  const _CompanionSummary({
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
      '추가 반영: ${nutrition.calories.toStringAsFixed(0)} kcal · 탄 ${nutrition.carbsG.toStringAsFixed(1)}g · '
      '단 ${nutrition.proteinG.toStringAsFixed(1)}g · 지 ${nutrition.fatG.toStringAsFixed(1)}g',
      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
    );
  }
}

class _MealChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _MealChips({required this.selected, required this.onChanged});

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
          onSelected: (isSelected) => onChanged(value),
        );
      }).toList(),
    );
  }
}
