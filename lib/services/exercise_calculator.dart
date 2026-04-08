class ExercisePreset {
  final String name;
  final double met;

  const ExercisePreset({
    required this.name,
    required this.met,
  });
}

class ExerciseCalculator {
  static const List<ExercisePreset> presets = [
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

  static double estimateCalories({
    required double weightKg,
    required double durationMinutes,
    required double met,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0 || met <= 0) return 0;
    return met * 3.5 * weightKg / 200 * durationMinutes;
  }
}
