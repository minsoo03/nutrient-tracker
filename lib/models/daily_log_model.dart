import 'package:cloud_firestore/cloud_firestore.dart';

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
      updatedAt: DateTime.now(),
    );
  }

  factory DailyLogModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DailyLogModel(
      date: data['date'] ?? '',
      totalCalories: (data['totalCalories'] ?? 0.0).toDouble(),
      totalCarbsG: (data['totalCarbsG'] ?? 0.0).toDouble(),
      totalProteinG: (data['totalProteinG'] ?? 0.0).toDouble(),
      totalFatG: (data['totalFatG'] ?? 0.0).toDouble(),
      totalSugarG: (data['totalSugarG'] ?? 0.0).toDouble(),
      totalFiberG: (data['totalFiberG'] ?? 0.0).toDouble(),
      totalSodiumMg: (data['totalSodiumMg'] ?? 0.0).toDouble(),
      totalCaffeineMg: (data['totalCaffeineMg'] ?? 0.0).toDouble(),
      totalAlcoholG: (data['totalAlcoholG'] ?? 0.0).toDouble(),
      totalExerciseCalories: (data['totalExerciseCalories'] ?? 0.0).toDouble(),
      totalWaterMl: (data['totalWaterMl'] ?? 0.0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'totalCalories': totalCalories,
      'totalCarbsG': totalCarbsG,
      'totalProteinG': totalProteinG,
      'totalFatG': totalFatG,
      'totalSugarG': totalSugarG,
      'totalFiberG': totalFiberG,
      'totalSodiumMg': totalSodiumMg,
      'totalCaffeineMg': totalCaffeineMg,
      'totalAlcoholG': totalAlcoholG,
      'totalExerciseCalories': totalExerciseCalories,
      'totalWaterMl': totalWaterMl,
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      totalExerciseCalories: totalExerciseCalories ?? this.totalExerciseCalories,
      totalWaterMl: totalWaterMl ?? this.totalWaterMl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
