import 'package:flutter/foundation.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/models/exercise_entry_model.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<DailyLogModel> getDailyLog(String uid, String date) async {
    final row = await _client
        .from('daily_logs')
        .select()
        .eq('user_id', uid)
        .eq('date', date)
        .maybeSingle();

    if (row == null) return DailyLogModel.empty(date);
    return DailyLogModel.fromSupabase(row);
  }

  Future<void> saveDailyLog(String uid, DailyLogModel log) async {
    await _client.from('daily_logs').upsert(
      {...log.toSupabase(), 'user_id': uid},
      onConflict: 'user_id,date',
    );
  }

  Stream<DailyLogModel> watchDailyLog(String uid, String date) async* {
    yield await getDailyLog(uid, date);
    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      yield await getDailyLog(uid, date);
    }
  }

  Future<void> saveDailyMedications(
    String uid,
    String date,
    List<String> medications,
  ) async {
    // defaultToNull: false → 명시하지 않은 컬럼(total_* 등)을 NULL로 덮어쓰지 않음
    await _client.from('daily_logs').upsert({
      'user_id': uid,
      'date': date,
      'daily_medications': medications,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,date', defaultToNull: false);
  }

  Future<void> rebuildDailyLogTotals(String uid, String date) async {
    final currentLog = await getDailyLog(uid, date);
    final foodRows = await _client
        .from('food_entries')
        .select()
        .eq('user_id', uid)
        .eq('log_date', date);
    final exerciseRows = await _client
        .from('exercise_entries')
        .select()
        .eq('user_id', uid)
        .eq('log_date', date);

    var totalCalories = 0.0, totalCarbsG = 0.0, totalProteinG = 0.0;
    var totalFatG = 0.0, totalSugarG = 0.0, totalFiberG = 0.0;
    var totalSodiumMg = 0.0, totalCaffeineMg = 0.0, totalAlcoholG = 0.0;

    for (final row in foodRows) {
      final entry = FoodEntryModel.fromSupabase(row);
      totalCalories += entry.calories;
      totalCarbsG += entry.carbsG;
      totalProteinG += entry.proteinG;
      totalFatG += entry.fatG;
      totalSugarG += entry.sugarG;
      totalFiberG += entry.fiberG;
      totalSodiumMg += entry.sodiumMg;
      totalCaffeineMg += entry.caffeineMg;
      totalAlcoholG += entry.alcoholG;
    }

    var totalExerciseCalories = 0.0;
    for (final row in exerciseRows) {
      totalExerciseCalories += ExerciseEntryModel.fromSupabase(row).burnedCalories;
    }

    await saveDailyLog(
      uid,
      currentLog.copyWith(
        date: date,
        totalCalories: totalCalories,
        totalCarbsG: totalCarbsG,
        totalProteinG: totalProteinG,
        totalFatG: totalFatG,
        totalSugarG: totalSugarG,
        totalFiberG: totalFiberG,
        totalSodiumMg: totalSodiumMg,
        totalCaffeineMg: totalCaffeineMg,
        totalAlcoholG: totalAlcoholG,
        totalExerciseCalories: totalExerciseCalories,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> addFoodEntry(
    String uid,
    String date,
    FoodEntryModel entry,
  ) async {
    try {
      await _client
          .from('food_entries')
          .insert(entry.toSupabase(uid: uid, date: date));
      await rebuildDailyLogTotals(uid, date);
    } catch (e, st) {
      debugPrint('❌ addFoodEntry 실패: uid=$uid, date=$date, error=$e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteFoodEntry(String uid, String date, String entryId) async {
    await _client.from('food_entries').delete().eq('user_id', uid).eq('id', entryId);
    await rebuildDailyLogTotals(uid, date);
  }

  Future<List<FoodEntryModel>> getEntries(String uid, String date) async {
    final rows = await _client
        .from('food_entries')
        .select()
        .eq('user_id', uid)
        .eq('log_date', date)
        .order('logged_at');
    return rows.map(FoodEntryModel.fromSupabase).toList();
  }

  Stream<List<FoodEntryModel>> watchEntries(String uid, String date) async* {
    yield await getEntries(uid, date);
    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      yield await getEntries(uid, date);
    }
  }

  Future<void> addExerciseEntry(
    String uid,
    String date,
    ExerciseEntryModel entry,
  ) async {
    try {
      await _client
          .from('exercise_entries')
          .insert(entry.toSupabase(uid: uid, date: date));
      await rebuildDailyLogTotals(uid, date);
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
    await _client
        .from('exercise_entries')
        .delete()
        .eq('user_id', uid)
        .eq('id', entryId);
    await rebuildDailyLogTotals(uid, date);
  }

  Future<List<ExerciseEntryModel>> getExerciseEntries(
    String uid,
    String date,
  ) async {
    final rows = await _client
        .from('exercise_entries')
        .select()
        .eq('user_id', uid)
        .eq('log_date', date)
        .order('logged_at');
    return rows.map(ExerciseEntryModel.fromSupabase).toList();
  }

  Stream<List<ExerciseEntryModel>> watchExerciseEntries(
    String uid,
    String date,
  ) async* {
    yield await getExerciseEntries(uid, date);
    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      yield await getExerciseEntries(uid, date);
    }
  }
}
