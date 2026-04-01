import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';

class GenderDropdown extends StatelessWidget {
  final Gender selectedGender;
  final ValueChanged<Gender?> onChanged;

  const GenderDropdown({
    required this.selectedGender,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Gender>(
      value: selectedGender,
      isExpanded: true,
      items: Gender.values.map((gender) {
        return DropdownMenuItem(
          value: gender,
          child: Text(gender.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class HealthGoalDropdown extends StatelessWidget {
  final HealthGoal selectedGoal;
  final ValueChanged<HealthGoal?> onChanged;

  const HealthGoalDropdown({
    required this.selectedGoal,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<HealthGoal>(
      value: selectedGoal,
      isExpanded: true,
      items: HealthGoal.values.map((goal) {
        return DropdownMenuItem(
          value: goal,
          child: Text(goal.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class DiseaseToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const DiseaseToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
