import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/auth/widgets/profile_form_widgets.dart';

/// 프로필 설정 3단계: 건강 상태 & 상시 복용약
class ProfileStep3 extends StatelessWidget {
  final bool hasKidney;
  final bool hasLiver;
  final List<String> medicationOptions;
  final List<String> selectedMedications;
  final ValueChanged<bool> onKidneyChanged;
  final ValueChanged<bool> onLiverChanged;
  final void Function(String medication, bool selected) onMedicationToggle;
  final VoidCallback onSave;
  final bool isLoading;

  const ProfileStep3({
    super.key,
    required this.hasKidney,
    required this.hasLiver,
    required this.medicationOptions,
    required this.selectedMedications,
    required this.onKidneyChanged,
    required this.onLiverChanged,
    required this.onMedicationToggle,
    required this.onSave,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('건강 상태',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('3 / 3', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('해당 항목 선택 시 영양소 목표가 맞춤 조정됩니다.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 24),
          DiseaseToggleRow(
            label: '신장 질환',
            description: '단백질·나트륨 섭취 기준이 낮아집니다',
            value: hasKidney,
            onChanged: onKidneyChanged,
          ),
          const SizedBox(height: 12),
          DiseaseToggleRow(
            label: '간 질환',
            description: '단백질 섭취 기준이 보수적으로 조정됩니다',
            value: hasLiver,
            onChanged: onLiverChanged,
          ),
          const SizedBox(height: 24),
          const Text('상시 복용약',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('계속 복용 중인 약을 저장합니다. 오늘 복용 약은 앱 안에서 따로 기록합니다.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: medicationOptions.map((medication) {
              final isSelected = selectedMedications.contains(medication);
              return FilterChip(
                label: Text(medication, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (selected) => onMedicationToggle(medication, selected),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: isLoading ? null : onSave,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('완료'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading ? null : onSave,
            child: Text('건너뛰기 (질병 없음)',
                style: TextStyle(color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }
}
