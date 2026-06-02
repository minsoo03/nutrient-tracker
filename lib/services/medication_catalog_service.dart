import 'package:flutter/foundation.dart';
import 'package:nutrient_tracker/services/medicine_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// medication_catalog 테이블 1행
class MedicationCatalogEntry {
  final String category;
  final String displayName;
  final String description;
  final double liverWeight;
  final double kidneyWeight;
  final bool sensitiveToProtein;
  final bool sensitiveToAlcohol;
  final bool sensitiveToCaffeine;
  final bool isChronic;
  final String? warningTitle;
  final String? warningDescription;
  final String? warningNutrient;

  const MedicationCatalogEntry({
    required this.category,
    required this.displayName,
    required this.description,
    required this.liverWeight,
    required this.kidneyWeight,
    required this.sensitiveToProtein,
    required this.sensitiveToAlcohol,
    required this.sensitiveToCaffeine,
    required this.isChronic,
    this.warningTitle,
    this.warningDescription,
    this.warningNutrient,
  });

  factory MedicationCatalogEntry.fromRow(Map<String, dynamic> r) {
    double num0(dynamic v) => (v as num? ?? 0).toDouble();
    return MedicationCatalogEntry(
      category: r['category'] as String,
      displayName: r['display_name'] as String? ?? r['category'] as String,
      description: r['description'] as String? ?? '',
      liverWeight: num0(r['liver_weight']),
      kidneyWeight: num0(r['kidney_weight']),
      sensitiveToProtein: r['sensitive_to_protein'] as bool? ?? false,
      sensitiveToAlcohol: r['sensitive_to_alcohol'] as bool? ?? false,
      sensitiveToCaffeine: r['sensitive_to_caffeine'] as bool? ?? false,
      isChronic: r['is_chronic'] as bool? ?? true,
      warningTitle: r['warning_title'] as String?,
      warningDescription: r['warning_description'] as String?,
      warningNutrient: r['warning_nutrient'] as String?,
    );
  }

  MedicationRiskProfile get asRiskProfile => MedicationRiskProfile(
        category: category,
        liverWeight: liverWeight,
        kidneyWeight: kidneyWeight,
        sensitiveToProtein: sensitiveToProtein,
        sensitiveToAlcohol: sensitiveToAlcohol,
        sensitiveToCaffeine: sensitiveToCaffeine,
      );

  MedicineWarning? get asWarning {
    if (warningTitle == null ||
        warningDescription == null ||
        warningNutrient == null) {
      return null;
    }
    return MedicineWarning(
      title: warningTitle!,
      description: warningDescription!,
      nutrient: warningNutrient!,
    );
  }
}

/// medication_catalog 테이블을 앱 시작 시 한 번 로드 → 메모리 캐시
/// 실패 시 빈 리스트 → MedicineService가 기존 하드코딩 데이터로 fallback
class MedicationCatalogService {
  static List<MedicationCatalogEntry> _cache = const [];
  static bool _loaded = false;

  static List<MedicationCatalogEntry> get cached => _cache;
  static bool get isLoaded => _loaded && _cache.isNotEmpty;

  static Future<void> loadAll() async {
    if (_loaded) return;
    try {
      final rows = await Supabase.instance.client
          .from('medication_catalog')
          .select()
          .order('category');
      _cache = rows.map(MedicationCatalogEntry.fromRow).toList();
      _loaded = true;
      debugPrint('💊 medication_catalog ${_cache.length}개 로드 완료');
    } catch (e) {
      debugPrint('💥 medication_catalog 로드 실패 → 하드코딩 fallback: $e');
      _loaded = true; // 재시도 방지
    }
  }
}
