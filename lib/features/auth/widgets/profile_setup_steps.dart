import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/widgets/numeric_input_field.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/widgets/profile_form_widgets.dart';

export 'package:nutrient_tracker/features/auth/widgets/profile_step3.dart'
    show ProfileStep3;

/// 프로필 설정 1단계: 기본 정보 (이름, 나이, 성별)
class ProfileStep1 extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  final Gender gender;
  final ValueChanged<Gender> onGenderChanged;
  final VoidCallback onNext;

  const ProfileStep1({
    super.key,
    required this.nameCtrl,
    required this.ageCtrl,
    required this.gender,
    required this.onGenderChanged,
    required this.onNext,
  });

  bool get _canProceed =>
      nameCtrl.text.trim().isNotEmpty &&
      (int.tryParse(ageCtrl.text) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('기본 정보',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('1 / 3', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 32),
          TextField(
            controller: nameCtrl,
            onChanged: (_) => (context as Element).markNeedsBuild(),
            decoration: const InputDecoration(
                labelText: '이름', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          NumericInputField(
            controller: ageCtrl,
            onChanged: (_) => (context as Element).markNeedsBuild(),
            labelText: '나이',
            suffixText: '세',
            allowDecimal: false,
          ),
          const SizedBox(height: 24),
          const Text('성별',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GenderSelector(selected: gender, onChanged: onGenderChanged),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: _canProceed ? onNext : null,
            child: const Text('다음'),
          ),
        ],
      ),
    );
  }
}

/// 프로필 설정 2단계: 체형 & 목표
class ProfileStep2 extends StatelessWidget {
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final HealthGoal goal;
  final ValueChanged<HealthGoal> onGoalChanged;
  final VoidCallback onNext;

  const ProfileStep2({
    super.key,
    required this.heightCtrl,
    required this.weightCtrl,
    required this.goal,
    required this.onGoalChanged,
    required this.onNext,
  });

  bool get _canProceed =>
      (double.tryParse(heightCtrl.text) ?? 0) > 0 &&
      (double.tryParse(weightCtrl.text) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('체형 & 목표',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('2 / 3', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: NumericInputField(
                controller: heightCtrl,
                onChanged: (_) => (context as Element).markNeedsBuild(),
                labelText: '키',
                suffixText: 'cm',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumericInputField(
                controller: weightCtrl,
                onChanged: (_) => (context as Element).markNeedsBuild(),
                labelText: '몸무게',
                suffixText: 'kg',
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Text('목표',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GoalSelector(selected: goal, onChanged: onGoalChanged),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _canProceed ? onNext : null,
            child: const Text('다음'),
          ),
        ],
      ),
    );
  }
}
