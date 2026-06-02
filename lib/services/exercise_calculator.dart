class ExercisePreset {
  final String name;
  final double met;

  const ExercisePreset({
    required this.name,
    required this.met,
  });
}

class ExerciseCalculator {
  /// 하드코딩 fallback 운동 (DB 로드 실패 또는 미초기화 상태에서 사용)
  static const List<ExercisePreset> _fallbackPresets = [
    ExercisePreset(name: '걷기', met: 3.8),
    ExercisePreset(name: '빠르게 걷기', met: 4.8),
    ExercisePreset(name: '조깅', met: 7.0),
    ExercisePreset(name: '러닝', met: 9.8),
    ExercisePreset(name: '자전거', met: 6.8),
    ExercisePreset(name: '근력운동', met: 5.0),
    ExercisePreset(name: '수영', met: 6.0),
    ExercisePreset(name: '계단 오르기', met: 8.8),
    ExercisePreset(name: '요가/스트레칭', met: 2.8),
  ];

  /// DB 로드 후 ExerciseCatalogService가 채워 넣는 동적 프리셋
  /// 순환참조 회피를 위해 단방향 등록 패턴 사용
  static List<ExercisePreset>? _dynamicPresets;

  /// 외부(ExerciseCatalogService)에서 DB 로드 완료 시 호출
  static void updateDynamicPresets(List<ExercisePreset> presets) {
    if (presets.isEmpty) return;
    _dynamicPresets = List.unmodifiable(presets);
  }

  /// 운동 프리셋 목록
  /// 1순위: DB의 exercise_catalog 캐시 (LLM 시드 데이터)
  /// 2순위: 하드코딩 _fallbackPresets
  static List<ExercisePreset> get presets =>
      _dynamicPresets ?? _fallbackPresets;

  static double estimateCalories({
    required double weightKg,
    required double durationMinutes,
    required double met,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0 || met <= 0) return 0;
    return met * 3.5 * weightKg / 200 * durationMinutes;
  }
}
