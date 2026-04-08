import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/manual_food_entry_form.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

Future<void> showManualFoodEntryDialog({
  required BuildContext context,
  required String uid,
  required String date,
  required NutritionService nutritionService,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _ManualFoodEntryDialog(
      uid: uid,
      date: date,
      nutritionService: nutritionService,
    ),
  );
}

class _ManualFoodEntryDialog extends StatefulWidget {
  final String uid;
  final String date;
  final NutritionService nutritionService;

  const _ManualFoodEntryDialog({
    required this.uid,
    required this.date,
    required this.nutritionService,
  });

  @override
  State<_ManualFoodEntryDialog> createState() => _ManualFoodEntryDialogState();
}

class _ManualFoodEntryDialogState extends State<_ManualFoodEntryDialog> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '100');
  final _caloriesCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();
  final _caffeineCtrl = TextEditingController();
  final _alcoholCtrl = TextEditingController();

  String _mealType = 'snack';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _caloriesCtrl.dispose();
    _carbsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _sugarCtrl.dispose();
    _fiberCtrl.dispose();
    _sodiumCtrl.dispose();
    _caffeineCtrl.dispose();
    _alcoholCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    final calories = double.tryParse(_caloriesCtrl.text.trim());

    if (name.isEmpty || amount == null || amount <= 0 || calories == null) {
      _showError('음식명, 섭취량, 칼로리를 올바르게 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final entry = FoodEntryModel(
        foodId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        foodName: name,
        amountG: amount,
        amountValue: amount,
        amountUnit: 'custom',
        entryType: 'manual',
        calories: calories,
        carbsG: _parseDouble(_carbsCtrl),
        proteinG: _parseDouble(_proteinCtrl),
        fatG: _parseDouble(_fatCtrl),
        sugarG: _parseDouble(_sugarCtrl),
        fiberG: _parseDouble(_fiberCtrl),
        sodiumMg: _parseDouble(_sodiumCtrl),
        caffeineMg: _parseDouble(_caffeineCtrl),
        alcoholG: _parseDouble(_alcoholCtrl),
        loggedAt: DateTime.now(),
        mealType: _mealType,
      );

      await widget.nutritionService.addFoodEntry(widget.uid, widget.date, entry);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name 추가됨 (${entry.displayAmountText})'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      _showError('직접 입력 저장 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _parseDouble(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0.0;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('직접 입력'),
      content: SingleChildScrollView(
        child: ManualFoodEntryForm(
          nameCtrl: _nameCtrl,
          amountCtrl: _amountCtrl,
          caloriesCtrl: _caloriesCtrl,
          carbsCtrl: _carbsCtrl,
          proteinCtrl: _proteinCtrl,
          fatCtrl: _fatCtrl,
          sugarCtrl: _sugarCtrl,
          fiberCtrl: _fiberCtrl,
          sodiumCtrl: _sodiumCtrl,
          caffeineCtrl: _caffeineCtrl,
          alcoholCtrl: _alcoholCtrl,
          mealType: _mealType,
          onMealTypeChanged: (v) => setState(() => _mealType = v),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('추가'),
        ),
      ],
    );
  }
}
