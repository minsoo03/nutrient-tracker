import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/services/medicine_service.dart';

/// 복용 약 관리 화면의 본문 위젯
class MedicationBody extends StatelessWidget {
  final UserModel userProfile;
  final List<String> dailySelected;
  final List<String> chronicSelected;
  final bool isSaving;
  final void Function(String medication, bool selected) onDailyToggled;
  final void Function(String medication, bool selected) onChronicToggled;
  final VoidCallback onSave;

  const MedicationBody({
    super.key,
    required this.userProfile,
    required this.dailySelected,
    required this.chronicSelected,
    required this.isSaving,
    required this.onDailyToggled,
    required this.onChronicToggled,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('오늘 복용한 약 카테고리',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('선택한 약만 오늘의 간/신장 무리 수치 계산에 반영됩니다.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          if (userProfile.medications.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('상시 복용약을 첫 선택값으로 불러왔습니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
          const SizedBox(height: 16),
          const Text('단기 복용약 빠른 선택',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MedicineService.acuteCategories.map((med) {
              final isSelected = dailySelected.contains(med);
              return FilterChip(
                label: Text(med),
                selected: isSelected,
                onSelected: (sel) => onDailyToggled(med, sel),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('오늘 복용 약 카테고리',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MedicineService.allCategories.map((med) {
              final isSelected = dailySelected.contains(med);
              return FilterChip(
                label: Text(med),
                selected: isSelected,
                onSelected: (sel) => onDailyToggled(med, sel),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('상시 복용약',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('피부과약, 혈압약, 고지혈증약처럼 계속 복용 중인 약을 저장합니다.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MedicineService.allCategories.map((med) {
              final isSelected = chronicSelected.contains(med);
              return FilterChip(
                label: Text(med),
                selected: isSelected,
                onSelected: (sel) => onChronicToggled(med, sel),
              );
            }).toList(),
          ),
          const Spacer(),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
    );
  }
}
