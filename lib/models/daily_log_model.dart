class DailyLogModel {
  final String date; // Format: "2026-04-02"
  final double totalCalories;
  final double totalCarbsG;
  final double totalProteinG;
  final double totalFatG;
  final double totalSugarG;
  final double totalFiberG;
  final double totalSodiumMg;
  final double totalCaffeineMg;
  final double totalAlcoholG;
  final double totalExerciseCalories;
  final double totalWaterMl;
  final List<String> dailyMedications;
  final DateTime updatedAt;

  DailyLogModel({
    required this.date,
    required this.totalCalories,
    required this.totalCarbsG,
    required this.totalProteinG,
    required this.totalFatG,
    required this.totalSugarG,
    required this.totalFiberG,
    required this.totalSodiumMg,
    required this.totalCaffeineMg,
    required this.totalAlcoholG,
    required this.totalExerciseCalories,
    required this.totalWaterMl,
    required this.dailyMedications,
    required this.updatedAt,
  });

  factory DailyLogModel.empty(String date) {
    return DailyLogModel(
      date: date,
      totalCalories: 0.0,
      totalCarbsG: 0.0,
      totalProteinG: 0.0,
      totalFatG: 0.0,
      totalSugarG: 0.0,
      totalFiberG: 0.0,
      totalSodiumMg: 0.0,
      totalCaffeineMg: 0.0,
      totalAlcoholG: 0.0,
      totalExerciseCalories: 0.0,
      totalWaterMl: 0.0,
      dailyMedications: const [],
      updatedAt: DateTime.now(),
    );
  }

  factory DailyLogModel.fromSupabase(Map<String, dynamic> data) {
    return DailyLogModel(
      date: data['date'] ?? '',
      totalCalories: (data['total_calories'] ?? 0.0).toDouble(),
      totalCarbsG: (data['total_carbs_g'] ?? 0.0).toDouble(),
      totalProteinG: (data['total_protein_g'] ?? 0.0).toDouble(),
      totalFatG: (data['total_fat_g'] ?? 0.0).toDouble(),
      totalSugarG: (data['total_sugar_g'] ?? 0.0).toDouble(),
      totalFiberG: (data['total_fiber_g'] ?? 0.0).toDouble(),
      totalSodiumMg: (data['total_sodium_mg'] ?? 0.0).toDouble(),
      totalCaffeineMg: (data['total_caffeine_mg'] ?? 0.0).toDouble(),
      totalAlcoholG: (data['total_alcohol_g'] ?? 0.0).toDouble(),
      totalExerciseCalories: (data['total_exercise_calories'] ?? 0.0)
          .toDouble(),
      totalWaterMl: (data['total_water_ml'] ?? 0.0).toDouble(),
      dailyMedications: List<String>.from(
        data['daily_medications'] ?? const [],
      ),
      updatedAt: _parseDate(data['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'date': date,
      'total_calories': totalCalories,
      'total_carbs_g': totalCarbsG,
      'total_protein_g': totalProteinG,
      'total_fat_g': totalFatG,
      'total_sugar_g': totalSugarG,
      'total_fiber_g': totalFiberG,
      'total_sodium_mg': totalSodiumMg,
      'total_caffeine_mg': totalCaffeineMg,
      'total_alcohol_g': totalAlcoholG,
      'total_exercise_calories': totalExerciseCalories,
      'total_water_ml': totalWaterMl,
      'daily_medications': dailyMedications,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  DailyLogModel copyWith({
    String? date,
    double? totalCalories,
    double? totalCarbsG,
    double? totalProteinG,
    double? totalFatG,
    double? totalSugarG,
    double? totalFiberG,
    double? totalSodiumMg,
    double? totalCaffeineMg,
    double? totalAlcoholG,
    double? totalExerciseCalories,
    double? totalWaterMl,
    List<String>? dailyMedications,
    DateTime? updatedAt,
  }) {
    return DailyLogModel(
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalCarbsG: totalCarbsG ?? this.totalCarbsG,
      totalProteinG: totalProteinG ?? this.totalProteinG,
      totalFatG: totalFatG ?? this.totalFatG,
      totalSugarG: totalSugarG ?? this.totalSugarG,
      totalFiberG: totalFiberG ?? this.totalFiberG,
      totalSodiumMg: totalSodiumMg ?? this.totalSodiumMg,
      totalCaffeineMg: totalCaffeineMg ?? this.totalCaffeineMg,
      totalAlcoholG: totalAlcoholG ?? this.totalAlcoholG,
      totalExerciseCalories:
          totalExerciseCalories ?? this.totalExerciseCalories,
      totalWaterMl: totalWaterMl ?? this.totalWaterMl,
      dailyMedications: dailyMedications ?? this.dailyMedications,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
