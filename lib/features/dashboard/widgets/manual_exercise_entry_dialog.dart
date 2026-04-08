import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/exercise_entry_form.dart';
import 'package:nutrient_tracker/models/exercise_entry_model.dart';
import 'package:nutrient_tracker/services/exercise_calculator.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

Future<void> showManualExerciseEntryDialog({
  required BuildContext context,
  required String uid,
  required String date,
  required double weightKg,
  required NutritionService nutritionService,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ManualExerciseEntryDialog(
      uid: uid,
      date: date,
      weightKg: weightKg,
      nutritionService: nutritionService,
    ),
  );
}

class _ManualExerciseEntryDialog extends StatefulWidget {
  final String uid;
  final String date;
  final double weightKg;
  final NutritionService nutritionService;

  const _ManualExerciseEntryDialog({
    required this.uid,
    required this.date,
    required this.weightKg,
    required this.nutritionService,
  });

  @override
  State<_ManualExerciseEntryDialog> createState() =>
      _ManualExerciseEntryDialogState();
}

class _ManualExerciseEntryDialogState
    extends State<_ManualExerciseEntryDialog> {
  final _durationCtrl = TextEditingController(text: '30');
  final _caloriesCtrl = TextEditingController();
  final _customNameCtrl = TextEditingController();
  String _selectedExercise = ExerciseCalculator.presets.first.name;
  bool _isLoading = false;
  bool _caloriesEditedManually = false;

  bool get _isCustomExercise =>
      _selectedExercise == ExerciseEntryForm.customExerciseLabel;

  ExercisePreset? get _selectedPreset {
    for (final preset in ExerciseCalculator.presets) {
      if (preset.name == _selectedExercise) return preset;
    }
    return null;
  }

  String get _resolvedExerciseName {
    if (_isCustomExercise) return _customNameCtrl.text.trim();
    return _selectedExercise;
  }

  @override
  void initState() {
    super.initState();
    _updateEstimatedCalories();
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _resolvedExerciseName;
    final duration = double.tryParse(_durationCtrl.text.trim());
    final calories = double.tryParse(_caloriesCtrl.text.trim());

    if (name.isEmpty || duration == null || duration <= 0 ||
        calories == null || calories <= 0) {
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
      await widget.nutritionService
          .addExerciseEntry(widget.uid, widget.date, entry);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name 운동 기록 추가됨'),
        backgroundColor: AppColors.primary,
      ));
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

  void _updateEstimatedCalories() {
    final duration = double.tryParse(_durationCtrl.text.trim());
    final preset = _selectedPreset;
    if (_caloriesEditedManually || duration == null || duration <= 0 ||
        preset == null) {
      return;
    }
    final estimated = ExerciseCalculator.estimateCalories(
      weightKg: widget.weightKg,
      durationMinutes: duration,
      met: preset.met,
    );
    _caloriesCtrl.text = estimated.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운동 추가'),
      content: SingleChildScrollView(
        child: ExerciseEntryForm(
          selectedExercise: _selectedExercise,
          isCustomExercise: _isCustomExercise,
          customNameCtrl: _customNameCtrl,
          durationCtrl: _durationCtrl,
          caloriesCtrl: _caloriesCtrl,
          weightKg: widget.weightKg,
          selectedPreset: _selectedPreset,
          isLoading: _isLoading,
          onExerciseChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedExercise = value;
              if (!_caloriesEditedManually) _updateEstimatedCalories();
            });
          },
          onDurationChanged: (_) {
            setState(() {
              if (!_caloriesEditedManually) _updateEstimatedCalories();
            });
          },
          onCaloriesManuallyEdited: (_) {
            _caloriesEditedManually = true;
          },
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
