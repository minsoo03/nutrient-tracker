import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/models/exercise_entry_model.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

Future<void> showManualExerciseEntryDialog({
  required BuildContext context,
  required String uid,
  required String date,
  required NutritionService nutritionService,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ManualExerciseEntryDialog(
      uid: uid,
      date: date,
      nutritionService: nutritionService,
    ),
  );
}

class _ManualExerciseEntryDialog extends StatefulWidget {
  final String uid;
  final String date;
  final NutritionService nutritionService;

  const _ManualExerciseEntryDialog({
    required this.uid,
    required this.date,
    required this.nutritionService,
  });

  @override
  State<_ManualExerciseEntryDialog> createState() =>
      _ManualExerciseEntryDialogState();
}

class _ManualExerciseEntryDialogState extends State<_ManualExerciseEntryDialog> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '30');
  final _caloriesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final duration = double.tryParse(_durationCtrl.text.trim());
    final calories = double.tryParse(_caloriesCtrl.text.trim());

    if (name.isEmpty || duration == null || duration <= 0 || calories == null || calories <= 0) {
      _showError('운동명, 시간, 소모 칼로리를 올바르게 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final entry = ExerciseEntryModel(
        exerciseName: name,
        durationMinutes: duration,
        burnedCalories: calories,
        loggedAt: DateTime.now(),
      );
      await widget.nutritionService.addExerciseEntry(widget.uid, widget.date, entry);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name 운동 기록 추가됨'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      _showError('운동 저장 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운동 추가'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '운동명',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              NumericInputField(
                controller: _durationCtrl,
                labelText: '운동 시간',
                suffixText: '분',
                allowDecimal: false,
              ),
              const SizedBox(height: 10),
              NumericInputField(
                controller: _caloriesCtrl,
                labelText: '소모 칼로리',
                suffixText: 'kcal',
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
}
