import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';

/// 체중 업데이트 다이얼로그를 표시하고 프로필을 저장한다.
/// 업데이트된 프로필 반환, 취소/오류 시 null.
Future<UserModel?> showWeightUpdateDialog({
  required BuildContext context,
  required UserModel profile,
  required AuthService authService,
}) async {
  final controller = TextEditingController(
    text: profile.weightKg.toStringAsFixed(
      profile.weightKg % 1 == 0 ? 0 : 1,
    ),
  );

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('체중 업데이트'),
      content: SizedBox(
        width: 320,
        child: NumericInputField(
          controller: controller,
          labelText: '현재 체중',
          suffixText: 'kg',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('저장'),
        ),
      ],
    ),
  );

  if (confirmed != true) return null;

  final weightKg = double.tryParse(controller.text.trim());
  if (weightKg == null || weightKg <= 0) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('체중을 올바르게 입력해주세요.'),
        backgroundColor: Colors.red,
      ));
    }
    return null;
  }

  final recalculated = NutritionCalculator.calculate(
    age: profile.age,
    gender: profile.gender,
    heightCm: profile.heightCm,
    weightKg: weightKg,
    goal: profile.goal,
    hasKidneyDisease: profile.hasKidneyDisease,
    hasLiverDisease: profile.hasLiverDisease,
  );

  final updatedProfile = profile.copyWith(
    weightKg: weightKg,
    dailyCalorieTarget: recalculated.calories,
    dailyProteinTarget: recalculated.proteinG,
    dailyCarbsTarget: recalculated.carbsG,
    dailyFatTarget: recalculated.fatG,
    dailySodiumTarget: recalculated.sodiumMg,
    lastWeightUpdatedAt: DateTime.now(),
  );

  await authService.saveUserProfile(updatedProfile);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('체중과 하루 권장치가 업데이트되었습니다.'),
      backgroundColor: AppColors.primary,
    ));
  }
  return updatedProfile;
}
