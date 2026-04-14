import 'package:nutrient_tracker/utils/portion_helper.dart';

class FoodEntryModel {
  final String? id;
  final String foodId;
  final String foodName;
  final double amountG;
  final double amountValue;
  final String amountUnit;
  final String entryType;
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
    required this.amountValue,
    required this.amountUnit,
    required this.entryType,
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

  Map<String, dynamic> toSupabase({required String uid, required String date}) {
    return {
      'user_id': uid,
      'log_date': date,
      'food_id': foodId,
      'food_name': foodName,
      'amount_g': amountG,
      'amount_value': amountValue,
      'amount_unit': amountUnit,
      'entry_type': entryType,
      'calories': calories,
      'carbs_g': carbsG,
      'protein_g': proteinG,
      'fat_g': fatG,
      'sugar_g': sugarG,
      'fiber_g': fiberG,
      'sodium_mg': sodiumMg,
      'caffeine_mg': caffeineMg,
      'alcohol_g': alcoholG,
      'logged_at': loggedAt.toIso8601String(),
      'meal_type': mealType,
    };
  }

  factory FoodEntryModel.fromSupabase(Map<String, dynamic> d) {
    final foodName = d['food_name'] ?? '';
    final amountG = (d['amount_g'] ?? 0.0).toDouble();
    final inferredUnit = _inferAmountUnit(foodName as String);
    return FoodEntryModel(
      id: d['id']?.toString(),
      foodId: d['food_id'] ?? '',
      foodName: foodName,
      amountG: amountG,
      amountValue: (d['amount_value'] ?? _inferAmountValue(foodName, amountG))
          .toDouble(),
      amountUnit: d['amount_unit'] ?? inferredUnit,
      entryType: d['entry_type'] ?? 'food',
      calories: (d['calories'] ?? 0.0).toDouble(),
      carbsG: (d['carbs_g'] ?? 0.0).toDouble(),
      proteinG: (d['protein_g'] ?? 0.0).toDouble(),
      fatG: (d['fat_g'] ?? 0.0).toDouble(),
      sugarG: (d['sugar_g'] ?? 0.0).toDouble(),
      fiberG: (d['fiber_g'] ?? 0.0).toDouble(),
      sodiumMg: (d['sodium_mg'] ?? 0.0).toDouble(),
      caffeineMg: (d['caffeine_mg'] ?? 0.0).toDouble(),
      alcoholG: (d['alcohol_g'] ?? 0.0).toDouble(),
      loggedAt: _parseDate(d['logged_at']) ?? DateTime.now(),
      mealType: d['meal_type'] ?? 'snack',
    );
  }

  String get displayAmountText {
    final value = amountValue % 1 == 0
        ? amountValue.toStringAsFixed(0)
        : amountValue.toStringAsFixed(1);
    return switch (amountUnit) {
      'piece' => '$value개',
      'ml' => '${value}ml',
      'custom' => value,
      _ => '${value}g',
    };
  }

  static String _inferAmountUnit(String foodName) {
    if (PortionHelper.usesPieceCount(foodName)) return 'piece';
    if (PortionHelper.usesMilliliters(foodName)) return 'ml';
    return 'g';
  }

  static double _inferAmountValue(String foodName, double amountG) {
    if (PortionHelper.usesPieceCount(foodName)) {
      return amountG / PortionHelper.gramsPerPiece(foodName);
    }
    return amountG;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
