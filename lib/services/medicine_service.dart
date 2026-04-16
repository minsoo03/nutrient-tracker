import 'package:nutrient_tracker/services/medicine_data.dart';
import 'package:nutrient_tracker/services/medicine_risk_profiles.dart';

export 'package:nutrient_tracker/services/medicine_data.dart'
    show MedicineWarning, MedicationRiskProfile;

class MedicineService {
  static const _nutrientThresholds = <String, double>{
    'sodiumMg': 2300,
    'caffeineMg': 400,
    'proteinG': 80,
    'fat': 65,
    'alcoholG': 14,
    'potassiumMg': 2000,
    'vitaminK': 120,
  };

  /// 약물 목록을 기반으로 관련 경고 반환
  static List<MedicineWarning> getWarnings(List<String> medications) {
    final result = <MedicineWarning>[];
    for (final med in medications) {
      for (final key in kMedicineWarnings.keys) {
        if (med.contains(key)) {
          result.addAll(kMedicineWarnings[key]!);
        }
      }
    }
    return result;
  }

  /// 영양소 값이 경고 기준을 초과하는지 확인
  static bool isOverLimit({
    required String nutrient,
    required double value,
    required List<MedicineWarning> warnings,
  }) {
    final threshold = _nutrientThresholds[nutrient];
    if (threshold == null) return false;
    return warnings.any((w) => w.nutrient == nutrient) && value >= threshold;
  }

  /// 모든 약물 카테고리 목록 (UI 선택용)
  static List<String> get allCategories => kMedicineWarnings.keys.toList();

  static List<String> get acuteCategories => kAcuteCategories;

  static List<MedicationRiskProfile> getRiskProfiles(List<String> medications) {
    final result = <MedicationRiskProfile>[];
    for (final med in medications) {
      for (final entry in kMedicationRiskProfiles.entries) {
        if (med.contains(entry.key)) {
          result.add(entry.value);
        }
      }
    }
    return result;
  }
}
