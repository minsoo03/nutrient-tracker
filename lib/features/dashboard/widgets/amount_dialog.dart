import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/amount_dialog_body.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/meal_companion_data.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/utils/portion_helper.dart';

/// 음식 섭취량 입력 다이얼로그
/// returns (amountG, mealType, extraNutrition, companionLabel,
///          caffeineOverrideMg, sugarOverrideG, isZeroDrink) or null
Future<(double, String, FoodNutrition, String?, double?, double?, bool)?>
    showAmountDialog(BuildContext context, FoodModel food) {
  return showDialog<(double, String, FoodNutrition, String?, double?, double?, bool)>(
    context: context,
    builder: (ctx) => _AmountDialog(food: food),
  );
}

class _AmountDialog extends StatefulWidget {
  final FoodModel food;
  const _AmountDialog({required this.food});

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _customCtrl = TextEditingController();
  final _caffeineCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _customRiceCtrl = TextEditingController();

  late List<PortionOption> _portions;
  late FoodInputProfile _inputProfile;
  double? _selectedGrams;
  bool _isCustom = false;
  bool _isZeroDrink = false;
  String _mealType = 'snack';
  MealCompanionOption _selectedRice = riceOptions[1];
  MealCompanionOption _selectedSideDish = sideDishOptions[1];

  @override
  void initState() {
    super.initState();
    _portions = PortionHelper.getPortions(widget.food.name);
    _inputProfile = PortionHelper.inputProfileFor(widget.food.name);
    if (_portions.isNotEmpty) _selectedGrams = _portions.first.grams;
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    _caffeineCtrl.dispose();
    _sugarCtrl.dispose();
    _customRiceCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final usesPiece = PortionHelper.usesPieceCount(widget.food.name);
    final usesMl = _inputProfile.usesMilliliters;
    double? grams;
    if (_isCustom) {
      final raw = resolveCustomAmount(widget.food.name, _customCtrl.text);
      if (raw != null && raw > 0) {
        // 인분 입력: 일반 음식은 1인분 = 100g으로 변환
        grams = usesPiece
            ? raw * PortionHelper.gramsPerPiece(widget.food.name)
            : usesMl ? raw : raw * 100.0;
      }
    } else {
      grams = _selectedGrams;
    }
    if (grams == null || grams <= 0) return;

    final resolvedRice =
        resolvedRiceOption(_selectedRice, _customRiceCtrl.text);
    final extraNutrition = _inputProfile.supportsMealCompanions
        ? resolvedRice.nutrition.plus(_selectedSideDish.nutrition)
        : kNoneNutrition;
    final companionLabel = _inputProfile.supportsMealCompanions
        ? buildCompanionLabel(resolvedRice, _selectedSideDish)
        : null;
    final caffeineOverride = double.tryParse(_caffeineCtrl.text);
    final sugarOverride =
        _isZeroDrink ? 0.0 : double.tryParse(_sugarCtrl.text);

    Navigator.pop(
      context,
      (
        grams,
        _mealType,
        extraNutrition,
        companionLabel,
        caffeineOverride,
        sugarOverride,
        _isZeroDrink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final isAveraged = food.variantCount > 1;
    final usesMl = _inputProfile.usesMilliliters;
    final usesPiece = PortionHelper.usesPieceCount(food.name);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(food.name,
              maxLines: 2, style: const TextStyle(fontSize: 15)),
          if (isAveraged)
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
                : (food.packageCaloriesSummary == null
                    ? food.displayBasisLabel
                    : '${food.displayBasisLabel} · ${food.packageCaloriesSummary}'),
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: AmountDialogBody(
          food: food,
          portions: _portions,
          inputProfile: _inputProfile,
          usesMl: usesMl,
          usesPiece: usesPiece,
          isCustom: _isCustom,
          selectedGrams: _selectedGrams,
          isZeroDrink: _isZeroDrink,
          mealType: _mealType,
          selectedRice: _selectedRice,
          selectedSideDish: _selectedSideDish,
          customCtrl: _customCtrl,
          caffeineCtrl: _caffeineCtrl,
          sugarCtrl: _sugarCtrl,
          customRiceCtrl: _customRiceCtrl,
          onIsCustomChanged: (v) => setState(() {
            _isCustom = v;
            if (v) _selectedGrams = null;
          }),
          onSelectedGramsChanged: (v) => setState(
              () { _isCustom = false; _selectedGrams = v; _customCtrl.clear(); }),
          onZeroDrinkChanged: (v) => setState(
              () { _isZeroDrink = v; if (v) _sugarCtrl.clear(); }),
          onMealTypeChanged: (v) => setState(() => _mealType = v),
          onRiceChanged: (v) => setState(
              () { _selectedRice = v; if (v.key != 'custom') _customRiceCtrl.clear(); }),
          onSideDishChanged: (v) => setState(() => _selectedSideDish = v),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(onPressed: _onConfirm, child: const Text('추가')),
      ],
    );
  }
}
