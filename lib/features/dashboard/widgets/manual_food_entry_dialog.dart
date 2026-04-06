import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
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
          content: Text('$name 추가됨'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      _showError('직접 입력 저장 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _parseDouble(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0.0;
  }

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
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nameCtrl, '음식명', TextInputType.text),
              const SizedBox(height: 10),
              _numericField(_amountCtrl, '섭취량', suffix: 'g/ml'),
              const SizedBox(height: 10),
              _numericField(_caloriesCtrl, '칼로리', suffix: 'kcal'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numericField(_carbsCtrl, '탄수화물', suffix: 'g')),
                  const SizedBox(width: 8),
                  Expanded(child: _numericField(_proteinCtrl, '단백질', suffix: 'g')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numericField(_fatCtrl, '지방', suffix: 'g')),
                  const SizedBox(width: 8),
                  Expanded(child: _numericField(_sugarCtrl, '당류', suffix: 'g')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numericField(_fiberCtrl, '식이섬유', suffix: 'g')),
                  const SizedBox(width: 8),
                  Expanded(child: _numericField(_sodiumCtrl, '나트륨', suffix: 'mg')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numericField(_caffeineCtrl, '카페인', suffix: 'mg')),
                  const SizedBox(width: 8),
                  Expanded(child: _numericField(_alcoholCtrl, '알코올', suffix: 'g')),
                ],
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '식사 구분',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
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

  Widget _field(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _numericField(
    TextEditingController controller,
    String label, {
    String? suffix,
  }) {
    return NumericInputField(
      controller: controller,
      labelText: label,
      suffixText: suffix,
    );
  }

  Widget _mealChip(String value, String label) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _mealType == value,
      onSelected: (selected) {
        if (!selected) return;
        setState(() => _mealType = value);
      },
    );
  }
}
