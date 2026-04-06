import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/utils/portion_helper.dart';

class FoodResultItem extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onTap;

  const FoodResultItem({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = food.per100g;
    final isAveraged = food.variantCount > 1;

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
        '단 ${n.proteinG.toStringAsFixed(1)}g · 지 ${n.fatG.toStringAsFixed(1)}g  (100g 기준)',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
    );
  }
}

/// 섭취량 다이얼로그 — returns (amountG, mealType) or null
Future<(double, String)?> showAmountDialog(
  BuildContext context,
  FoodModel food,
) async {
  final portions = PortionHelper.getPortions(food.name);
  final customCtrl = TextEditingController();
  double? selectedGrams = portions.isNotEmpty ? portions.first.grams : null;
  bool isCustom = portions.isEmpty;
  String mealType = 'snack';
  (double, String)? result;

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
              Text('${food.variantCount}종 데이터 평균값',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(
              '칼로리 ${food.per100g.calories.toStringAsFixed(0)} kcal · '
              '탄 ${food.per100g.carbsG.toStringAsFixed(1)}g · '
              '단 ${food.per100g.proteinG.toStringAsFixed(1)}g · '
              '지 ${food.per100g.fatG.toStringAsFixed(1)}g',
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
                TextField(
                  controller: customCtrl,
                  autofocus: portions.isEmpty,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '직접 입력',
                    suffixText: 'g',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
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
              if (grams != null && grams > 0) result = (grams, mealType);
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
