class ExerciseEntryModel {
  final String? id;
  final String exerciseName;
  final double durationMinutes;
  final double burnedCalories;
  final DateTime loggedAt;

  const ExerciseEntryModel({
    this.id,
    required this.exerciseName,
    required this.durationMinutes,
    required this.burnedCalories,
    required this.loggedAt,
  });

  Map<String, dynamic> toSupabase({required String uid, required String date}) {
    return {
      'user_id': uid,
      'log_date': date,
      'exercise_name': exerciseName,
      'duration_minutes': durationMinutes,
      'burned_calories': burnedCalories,
      'logged_at': loggedAt.toUtc().toIso8601String(),
    };
  }

  factory ExerciseEntryModel.fromSupabase(Map<String, dynamic> d) {
    return ExerciseEntryModel(
      id: d['id']?.toString(),
      exerciseName: d['exercise_name'] ?? '',
      durationMinutes: (d['duration_minutes'] ?? 0.0).toDouble(),
      burnedCalories: (d['burned_calories'] ?? 0.0).toDouble(),
      loggedAt: _parseDate(d['logged_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
