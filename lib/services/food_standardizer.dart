import 'package:nutrient_tracker/data/food_alcohol_data.dart';
import 'package:nutrient_tracker/data/food_brand_catalog.dart';
import 'package:nutrient_tracker/models/food_model.dart';

/// 브랜드/알코올/계란/프로틴 표준 결과 앞에 삽입하는 서비스
class FoodStandardizer {
  /// 표준 결과를 검색 결과 앞에 붙여 반환
  static List<FoodModel> prepend(String query, List<FoodModel> results) {
    final standardized = <FoodModel>[
      ..._brandResults(query),
      ..._alcoholResults(query),
      ..._eggResults(query),
      if (_isProteinQuery(query)) kProteinShake,
    ];
    if (standardized.isEmpty) return results;

    final merged = <FoodModel>[...standardized, ...results];
    final seen = <String>{};
    return merged
        .where((food) => seen.add('${food.source}:${food.name}'))
        .toList();
  }

  static List<FoodModel> _brandResults(String query) {
    final normalized = query.toLowerCase().replaceAll(' ', '');
    final results = <FoodModel>[];
    for (final entry in brandAliasToStandard.entries) {
      final key = entry.key.toLowerCase().replaceAll(' ', '');
      if (!normalized.contains(key)) continue;
      final standard = brandCatalog[entry.value];
      if (standard != null) results.add(standard);
    }
    final seen = <String>{};
    return results.where((food) => seen.add(food.id)).toList();
  }

  static List<FoodModel> _alcoholResults(String query) {
    if (!_isAlcoholQuery(query)) return [];
    final normalized = query.toLowerCase().replaceAll(' ', '');
    final matches = alcoholCatalogEntries
        .where((entry) =>
            entry.$1.any((keyword) => normalized.contains(keyword)))
        .map((entry) => entry.$2)
        .toList();

    if (matches.isNotEmpty) return matches;
    if (normalized.contains('술') || normalized.contains('alcohol')) {
      return alcoholCatalogEntries.map((entry) => entry.$2).toList();
    }
    return [];
  }

  static List<FoodModel> _eggResults(String query) {
    final lower = query.toLowerCase();
    final isEggQuery = query.contains('계란') || query.contains('달걀') ||
        lower.contains('egg');
    if (!isEggQuery) return [];

    if (_isFriedEggQuery(query)) return const [kFriedEgg];

    // "스크램블" 검색
    if (lower.contains('scramble') || query.contains('스크램블')) {
      return const [kScrambledEgg];
    }
    // "삶은" 검색
    if (query.contains('삶') || lower.contains('boil') || lower.contains('hard')) {
      return const [kBoiledEgg];
    }
    // 단순 "계란"/"달걀" → 자주 쓰는 순서로 전부 제공
    return const [kBoiledEgg, kFriedEgg, kRawEgg, kScrambledEgg];
  }

  static bool _isAlcoholQuery(String query) {
    final lower = query.toLowerCase();
    return query.contains('술') ||
        query.contains('소주') ||
        query.contains('맥주') ||
        query.contains('와인') ||
        query.contains('막걸리') ||
        query.contains('위스키') ||
        query.contains('하이볼') ||
        lower.contains('alcohol') ||
        lower.contains('beer') ||
        lower.contains('wine') ||
        lower.contains('soju') ||
        lower.contains('whiskey') ||
        lower.contains('whisky') ||
        lower.contains('highball') ||
        lower.contains('liquor');
  }

  static bool _isFriedEggQuery(String query) {
    final lower = query.toLowerCase();
    return query.contains('계란 후라이') ||
        query.contains('계란후라이') ||
        query.contains('달걀 후라이') ||
        query.contains('달걀후라이') ||
        query.contains('후라이드 에그') ||
        query.contains('후라이드에그') ||
        lower.contains('fried egg');
  }

  static bool _isProteinQuery(String query) {
    final lower = query.toLowerCase();
    return lower.contains('protein') ||
        lower.contains('whey') ||
        lower.contains('shake') ||
        query.contains('프로틴') ||
        query.contains('단백질') ||
        query.contains('보충제');
  }
}
