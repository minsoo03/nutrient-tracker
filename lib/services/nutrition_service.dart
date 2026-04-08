import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/models/exercise_entry_model.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _logsCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('daily_logs');

  CollectionReference<Map<String, dynamic>> _entriesCol(
    String uid,
    String date,
  ) => _logsCol(uid).doc(date).collection('entries');

  CollectionReference<Map<String, dynamic>> _exercisesCol(
    String uid,
    String date,
  ) => _logsCol(uid).doc(date).collection('exercises');

  /// Retrieve daily log for a specific date.
  Future<DailyLogModel> getDailyLog(String uid, String date) async {
    final doc = await _logsCol(uid).doc(date).get();
    if (doc.exists) {
      return DailyLogModel.fromFirestore(doc);
    }
    return DailyLogModel.empty(date);
  }

  /// Save or update daily log totals.
  Future<void> saveDailyLog(String uid, DailyLogModel log) async {
    await _logsCol(uid).doc(log.date).set(
          log.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Watch daily log changes in real-time.
  Stream<DailyLogModel> watchDailyLog(String uid, String date) {
    return _logsCol(uid).doc(date).snapshots().map((doc) {
      if (doc.exists) {
        return DailyLogModel.fromFirestore(doc);
      }
      return DailyLogModel.empty(date);
    });
  }

  Future<void> saveDailyMedications(
    String uid,
    String date,
    List<String> medications,
  ) async {
    final current = await getDailyLog(uid, date);
    await saveDailyLog(
      uid,
      current.copyWith(
        dailyMedications: medications,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Add a food entry and recalculate daily totals.
  Future<void> addFoodEntry(
    String uid,
    String date,
    FoodEntryModel entry,
  ) async {
    try {
      await _entriesCol(uid, date).add(entry.toFirestore());
      await _recalculateDailyTotals(uid, date);
    } catch (e, st) {
      debugPrint('❌ addFoodEntry 실패: uid=$uid, date=$date, error=$e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// Delete a food entry and recalculate daily totals.
  Future<void> deleteFoodEntry(
    String uid,
    String date,
    String entryId,
  ) async {
    await _entriesCol(uid, date).doc(entryId).delete();
    await _recalculateDailyTotals(uid, date);
  }

  /// Watch food entries for a specific date.
  Stream<List<FoodEntryModel>> watchEntries(String uid, String date) {
    return _entriesCol(uid, date)
        .orderBy('logged_at', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(FoodEntryModel.fromFirestore)
              .toList(),
        );
  }

  Future<void> addExerciseEntry(
    String uid,
    String date,
    ExerciseEntryModel entry,
  ) async {
    try {
      await _exercisesCol(uid, date).add(entry.toFirestore());
      await _recalculateDailyTotals(uid, date);
    } catch (e, st) {
      debugPrint('❌ addExerciseEntry 실패: uid=$uid, date=$date, error=$e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteExerciseEntry(
    String uid,
    String date,
    String entryId,
  ) async {
    await _exercisesCol(uid, date).doc(entryId).delete();
    await _recalculateDailyTotals(uid, date);
  }

  Stream<List<ExerciseEntryModel>> watchExerciseEntries(String uid, String date) {
    return _exercisesCol(uid, date)
        .orderBy('logged_at', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(ExerciseEntryModel.fromFirestore)
              .toList(),
        );
  }

  Future<void> _recalculateDailyTotals(String uid, String date) async {
    final snap = await _entriesCol(uid, date).get();
    final exerciseSnap = await _exercisesCol(uid, date).get();
    final currentLog = await getDailyLog(uid, date);
    double cal = 0, carbs = 0, protein = 0, fat = 0;
    double sugar = 0, fiber = 0, sodium = 0, caffeine = 0, alcohol = 0;
    double exerciseCalories = 0;

    for (final doc in snap.docs) {
      final d = doc.data();
      cal += (d['calories'] ?? 0.0).toDouble();
      carbs += (d['carbs_g'] ?? 0.0).toDouble();
      protein += (d['protein_g'] ?? 0.0).toDouble();
      fat += (d['fat_g'] ?? 0.0).toDouble();
      sugar += (d['sugar_g'] ?? 0.0).toDouble();
      fiber += (d['fiber_g'] ?? 0.0).toDouble();
      sodium += (d['sodium_mg'] ?? 0.0).toDouble();
      caffeine += (d['caffeine_mg'] ?? 0.0).toDouble();
      alcohol += (d['alcohol_g'] ?? 0.0).toDouble();
    }

    for (final doc in exerciseSnap.docs) {
      final d = doc.data();
      exerciseCalories += (d['burned_calories'] ?? 0.0).toDouble();
    }

    final log = DailyLogModel(
      date: date,
      totalCalories: cal,
      totalCarbsG: carbs,
      totalProteinG: protein,
      totalFatG: fat,
      totalSugarG: sugar,
      totalFiberG: fiber,
      totalSodiumMg: sodium,
      totalCaffeineMg: caffeine,
      totalAlcoholG: alcohol,
      totalExerciseCalories: exerciseCalories,
      totalWaterMl: 0,
      dailyMedications: currentLog.dailyMedications,
      updatedAt: DateTime.now(),
    );
    await saveDailyLog(uid, log);
  }
}
