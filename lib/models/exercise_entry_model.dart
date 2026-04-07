import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toFirestore() {
    return {
      'exercise_name': exerciseName,
      'duration_minutes': durationMinutes,
      'burned_calories': burnedCalories,
      'logged_at': Timestamp.fromDate(loggedAt),
    };
  }

  factory ExerciseEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ExerciseEntryModel(
      id: doc.id,
      exerciseName: d['exercise_name'] ?? '',
      durationMinutes: (d['duration_minutes'] ?? 0.0).toDouble(),
      burnedCalories: (d['burned_calories'] ?? 0.0).toDouble(),
      loggedAt: (d['logged_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
