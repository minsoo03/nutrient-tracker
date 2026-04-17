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
  /// "감기약:3" 형식의 수량 인코딩도 지원
  static List<MedicineWarning> getWarnings(List<String> medications) {
    final result = <MedicineWarning>[];
    for (final med in medications) {
      final name = _parseName(med);
      for (final key in kMedicineWarnings.keys) {
        if (name.contains(key)) {
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

  /// 약물 목록을 기반으로 리스크 프로필 반환
  /// "감기약:3" 형식 지원 — 수량에 따라 가중치 자동 조정
  static List<MedicationRiskProfile> getRiskProfiles(List<String> medications) {
    final result = <MedicationRiskProfile>[];
    for (final med in medications) {
      final name = _parseName(med);
      final factor = _doseFactor(_parseDose(med));
      for (final entry in kMedicationRiskProfiles.entries) {
        if (name.contains(entry.key)) {
          result.add(factor == 1.0 ? entry.value : entry.value.scaled(factor));
        }
      }
    }
    return result;
  }

  /// "감기약:3" → "감기약"
  static String _parseName(String med) => med.split(':').first.trim();

  /// "감기약:3" → 3, "감기약" → 1
  static int _parseDose(String med) {
    final parts = med.split(':');
    if (parts.length < 2) return 1;
    return int.tryParse(parts[1].trim()) ?? 1;
  }

  /// 복용 수량 → 가중치 배수
  /// 1알=1.0, 2알=1.5, 3알=2.0, 4+알=2.5
  static double _doseFactor(int dose) {
    if (dose <= 1) return 1.0;
    if (dose == 2) return 1.5;
    if (dose == 3) return 2.0;
    return 2.5;
  }

  /// "감기약:3" 형식으로 인코딩
  static String encodeDose(String name, int dose) =>
      dose > 1 ? '$name:$dose' : name;

  /// List<String>에서 약이름→수량 Map 파싱
  static Map<String, int> decodeDoses(List<String> medications) {
    return {
      for (final med in medications) _parseName(med): _parseDose(med),
    };
  }
}
