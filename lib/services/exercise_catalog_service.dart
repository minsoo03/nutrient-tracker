import 'package:flutter/foundation.dart';
import 'package:nutrient_tracker/services/exercise_calculator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// exercise_catalog 테이블 1행
class ExerciseCatalogEntry {
  final String name;
  final String category;
  final double met;
  final String intensity;
  final int recommendedDurationMin;
  final String description;

  const ExerciseCatalogEntry({
    required this.name,
    required this.category,
    required this.met,
    required this.intensity,
    required this.recommendedDurationMin,
    required this.description,
  });

  factory ExerciseCatalogEntry.fromRow(Map<String, dynamic> r) {
    return ExerciseCatalogEntry(
      name: r['name'] as String,
      category: r['category'] as String? ?? '기타',
      met: (r['met'] as num? ?? 0).toDouble(),
      intensity: r['intensity'] as String? ?? 'medium',
      recommendedDurationMin: (r['recommended_duration_min'] as num? ?? 30).toInt(),
      description: r['description'] as String? ?? '',
    );
  }

  ExercisePreset get asPreset => ExercisePreset(name: name, met: met);
}

/// exercise_catalog 테이블을 앱 시작 시 한 번 로드 → 메모리 캐시
/// 실패 시 빈 리스트 → ExerciseCalculator가 기존 하드코딩 presets로 fallback
class ExerciseCatalogService {
  static List<ExerciseCatalogEntry> _cache = const [];
  static bool _loaded = false;

  static List<ExerciseCatalogEntry> get cached => _cache;
  static bool get isLoaded => _loaded && _cache.isNotEmpty;

  /// 캐시에서 ExercisePreset 형태로 변환 (UI 호환성용)
  static List<ExercisePreset> get cachedPresets =>
      _cache.map((e) => e.asPreset).toList();

  static Future<void> loadAll() async {
    if (_loaded) return;
    try {
      final rows = await Supabase.instance.client
          .from('exercise_catalog')
          .select()
          .order('category')
          .order('met');
      _cache = rows.map(ExerciseCatalogEntry.fromRow).toList();
      _loaded = true;
      // ExerciseCalculator.presets가 DB 데이터를 쓰도록 동적 등록
      ExerciseCalculator.updateDynamicPresets(cachedPresets);
      debugPrint('🏃 exercise_catalog ${_cache.length}개 로드 완료');
    } catch (e) {
      debugPrint('💥 exercise_catalog 로드 실패 → 하드코딩 fallback: $e');
      _loaded = true; // 재시도 방지
    }
  }
}
