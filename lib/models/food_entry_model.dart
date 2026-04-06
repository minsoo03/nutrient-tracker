import 'package:cloud_firestore/cloud_firestore.dart';

class FoodEntryModel {
  final String? id;
  final String foodId;
  final String foodName;
  final double amountG;
  final double calories;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double sugarG;
  final double fiberG;
  final double sodiumMg;
  final double caffeineMg;
  final double alcoholG;
  final DateTime loggedAt;
  final String mealType; // breakfast | lunch | dinner | snack

  const FoodEntryModel({
    this.id,
    required this.foodId,
    required this.foodName,
    required this.amountG,
    required this.calories,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.sugarG,
    required this.fiberG,
    required this.sodiumMg,
    required this.caffeineMg,
    required this.alcoholG,
    required this.loggedAt,
    required this.mealType,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'amount_g': amountG,
      'calories': calories,
      'carbs_g': carbsG,
      'protein_g': proteinG,
      'fat_g': fatG,
      'sugar_g': sugarG,
      'fiber_g': fiberG,
      'sodium_mg': sodiumMg,
      'caffeine_mg': caffeineMg,
      'alcohol_g': alcoholG,
      'logged_at': Timestamp.fromDate(loggedAt),
      'meal_type': mealType,
    };
  }

  factory FoodEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return FoodEntryModel(
      id: doc.id,
      foodId: d['food_id'] ?? '',
      foodName: d['food_name'] ?? '',
      amountG: (d['amount_g'] ?? 0.0).toDouble(),
      calories: (d['calories'] ?? 0.0).toDouble(),
      carbsG: (d['carbs_g'] ?? 0.0).toDouble(),
      proteinG: (d['protein_g'] ?? 0.0).toDouble(),
      fatG: (d['fat_g'] ?? 0.0).toDouble(),
      sugarG: (d['sugar_g'] ?? 0.0).toDouble(),
      fiberG: (d['fiber_g'] ?? 0.0).toDouble(),
      sodiumMg: (d['sodium_mg'] ?? 0.0).toDouble(),
      caffeineMg: (d['caffeine_mg'] ?? 0.0).toDouble(),
      alcoholG: (d['alcohol_g'] ?? 0.0).toDouble(),
      loggedAt: (d['logged_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mealType: d['meal_type'] ?? 'snack',
    );
  }
}
