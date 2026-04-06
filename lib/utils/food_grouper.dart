import 'package:nutrient_tracker/models/food_model.dart';

/// 검색 결과에서 유사한 음식끼리 묶고 영양성분 평균값을 계산
class FoodGrouper {
  /// foods 리스트를 이름 기준으로 그룹핑 후 평균 FoodModel 반환
  static List<FoodModel> groupAndAverage(List<FoodModel> foods) {
    if (foods.isEmpty) return [];

    final groups = <String, List<FoodModel>>{};
    for (final food in foods) {
      final key = _normalizeKey(food.name);
      groups.putIfAbsent(key, () => []).add(food);
    }

    return groups.values.map(_averageGroup).toList();
  }

  /// 이름 전체를 정규화해서 같은 음식명끼리만 평균화한다.
  /// 예: "김치 찌개", "김치찌개" -> "김치찌개"
  static String _normalizeKey(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[,\(\)\[\]/]'), ' ')
        .replaceAll(RegExp(r'\s+'), '');
  }

  static FoodModel _averageGroup(List<FoodModel> group) {
    if (group.length == 1) return group.first;

    double avg(double Function(FoodModel f) fn) =>
        group.map(fn).reduce((a, b) => a + b) / group.length;

    // 대표명: 가장 짧은 이름
    final name = group
        .map((f) => f.name)
        .reduce((a, b) => a.length <= b.length ? a : b);

    return FoodModel(
      id: group.first.id,
      name: name,
      source: group.first.source,
      nutritionBasisLabel: '100g',
      packageAmount: null,
      packageUnit: null,
      variantCount: group.length,
      per100g: FoodNutrition(
        calories:   avg((f) => f.per100g.calories),
        carbsG:     avg((f) => f.per100g.carbsG),
        proteinG:   avg((f) => f.per100g.proteinG),
        fatG:       avg((f) => f.per100g.fatG),
        sugarG:     avg((f) => f.per100g.sugarG),
        fiberG:     avg((f) => f.per100g.fiberG),
        sodiumMg:   avg((f) => f.per100g.sodiumMg),
        caffeineMg: avg((f) => f.per100g.caffeineMg),
        alcoholG:   avg((f) => f.per100g.alcoholG),
      ),
    );
  }
}
