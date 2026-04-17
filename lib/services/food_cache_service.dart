import 'package:flutter/foundation.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase `branded_foods` 테이블을 읽기/쓰기 전담
/// - search(): 쿼리로 캐시 조회
/// - saveAll(): API 결과를 캐시에 저장 (upsert)
class FoodCacheService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<FoodModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final rows = await _client
          .from('branded_foods')
          .select()
          .ilike('food_name', '%$query%')
          .limit(40);
      return rows.map(_fromRow).toList();
    } catch (e) {
      debugPrint('💥 [cache] 검색 실패: $e');
      return [];
    }
  }

  static Future<void> saveAll(List<FoodModel> foods) async {
    if (foods.isEmpty) return;
    try {
      final rows = foods.map(_toRow).toList();
      await _client.from('branded_foods').upsert(rows, onConflict: 'id');
      debugPrint('✅ [cache] ${foods.length}개 저장 완료');
    } catch (e) {
      debugPrint('💥 [cache] 저장 실패: $e');
    }
  }

  static FoodModel _fromRow(Map<String, dynamic> r) {
    return FoodModel(
      id: r['id'] as String,
      name: r['food_name'] as String,
      source: r['source'] as String? ?? 'cached',
      makerName: _str(r['maker_name']),
      itemReportNo: _str(r['item_report_no']),
      dbGroupCode: _str(r['db_group_code']),
      dbGroupName: _str(r['db_group_name']),
      dbClassCode: _str(r['db_class_code']),
      dbClassName: _str(r['db_class_name']),
      nutritionBasisLabel: r['nutrition_basis_label'] as String? ?? '100g',
      servingAmount: (r['serving_amount'] as num?)?.toDouble(),
      servingUnit: _str(r['serving_unit']),
      packageAmount: (r['package_amount'] as num?)?.toDouble(),
      packageUnit: _str(r['package_unit']),
      per100g: FoodNutrition(
        calories: (r['calories_per_100'] as num? ?? 0).toDouble(),
        carbsG: (r['carbs_g_per_100'] as num? ?? 0).toDouble(),
        proteinG: (r['protein_g_per_100'] as num? ?? 0).toDouble(),
        fatG: (r['fat_g_per_100'] as num? ?? 0).toDouble(),
        sugarG: (r['sugar_g_per_100'] as num? ?? 0).toDouble(),
        fiberG: (r['fiber_g_per_100'] as num? ?? 0).toDouble(),
        sodiumMg: (r['sodium_mg_per_100'] as num? ?? 0).toDouble(),
        caffeineMg: (r['caffeine_mg_per_100'] as num? ?? 0).toDouble(),
        alcoholG: (r['alcohol_g_per_100'] as num? ?? 0).toDouble(),
      ),
    );
  }

  static Map<String, dynamic> _toRow(FoodModel f) {
    return {
      'id': f.id,
      'food_name': f.name,
      'maker_name': f.makerName ?? '',
      'item_report_no': f.itemReportNo ?? '',
      'db_group_code': f.dbGroupCode ?? '',
      'db_group_name': f.dbGroupName ?? '',
      'db_class_code': f.dbClassCode ?? '',
      'db_class_name': f.dbClassName ?? '',
      'nutrition_basis_label': f.nutritionBasisLabel,
      'serving_amount': f.servingAmount,
      'serving_unit': f.servingUnit,
      'package_amount': f.packageAmount,
      'package_unit': f.packageUnit,
      'calories_per_100': f.per100g.calories,
      'carbs_g_per_100': f.per100g.carbsG,
      'protein_g_per_100': f.per100g.proteinG,
      'fat_g_per_100': f.per100g.fatG,
      'sugar_g_per_100': f.per100g.sugarG,
      'fiber_g_per_100': f.per100g.fiberG,
      'sodium_mg_per_100': f.per100g.sodiumMg,
      'caffeine_mg_per_100': f.per100g.caffeineMg,
      'alcohol_g_per_100': f.per100g.alcoholG,
      'source': f.source,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// null 또는 빈 문자열이면 null 반환
  static String? _str(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }
}
