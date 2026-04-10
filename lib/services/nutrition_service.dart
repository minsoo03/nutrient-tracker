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
    await _logsCol(uid).doc(date).set(
      {
        'date': date,
        'dailyMedications': medications,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }

  /// Add a food entry and recalculate daily totals.
  Future<void> addFoodEntry(
    String uid,
    String date,
    FoodEntryModel entry,
  ) async {
    try {
      final batch = _firestore.batch();
      final entryRef = _entriesCol(uid, date).doc();
      batch.set(entryRef, entry.toFirestore());
      _applyFoodDelta(batch, uid, date, entry, 1);
      await batch.commit();
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
    final entryRef = _entriesCol(uid, date).doc(entryId);
    final doc = await entryRef.get();
    if (!doc.exists) return;

    final entry = FoodEntryModel.fromFirestore(doc);
    final batch = _firestore.batch();
    batch.delete(entryRef);
    _applyFoodDelta(batch, uid, date, entry, -1);
    await batch.commit();
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
      final batch = _firestore.batch();
      final entryRef = _exercisesCol(uid, date).doc();
      batch.set(entryRef, entry.toFirestore());
      _applyExerciseDelta(batch, uid, date, entry.burnedCalories);
      await batch.commit();
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
    final entryRef = _exercisesCol(uid, date).doc(entryId);
    final doc = await entryRef.get();
    if (!doc.exists) return;

    final entry = ExerciseEntryModel.fromFirestore(doc);
    final batch = _firestore.batch();
    batch.delete(entryRef);
    _applyExerciseDelta(batch, uid, date, -entry.burnedCalories);
    await batch.commit();
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

  void _applyFoodDelta(
    WriteBatch batch,
    String uid,
    String date,
    FoodEntryModel entry,
    int direction,
  ) {
    final multiplier = direction.toDouble();
    batch.set(
      _logsCol(uid).doc(date),
      {
        'date': date,
        'totalCalories': FieldValue.increment(entry.calories * multiplier),
        'totalCarbsG': FieldValue.increment(entry.carbsG * multiplier),
        'totalProteinG': FieldValue.increment(entry.proteinG * multiplier),
        'totalFatG': FieldValue.increment(entry.fatG * multiplier),
        'totalSugarG': FieldValue.increment(entry.sugarG * multiplier),
        'totalFiberG': FieldValue.increment(entry.fiberG * multiplier),
        'totalSodiumMg': FieldValue.increment(entry.sodiumMg * multiplier),
        'totalCaffeineMg': FieldValue.increment(entry.caffeineMg * multiplier),
        'totalAlcoholG': FieldValue.increment(entry.alcoholG * multiplier),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }

  void _applyExerciseDelta(
    WriteBatch batch,
    String uid,
    String date,
    double burnedCaloriesDelta,
  ) {
    batch.set(
      _logsCol(uid).doc(date),
      {
        'date': date,
        'totalExerciseCalories': FieldValue.increment(burnedCaloriesDelta),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }
}
