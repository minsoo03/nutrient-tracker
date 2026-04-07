import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/services/korean_food_service.dart';

class FoodSearchService {
  static const _usdaBase = 'https://api.nal.usda.gov/fdc/v1';
  static const _usdaKey = 'DEMO_KEY'; // 실 서비스 시 교체 필요
  static const _koreanToEnglishAliases = <String, List<String>>{
    '시리얼': ['cereal', 'breakfast cereal', 'granola'],
    '그래놀라': ['granola', 'cereal'],
    '프로틴 쉐이크': ['protein shake', 'protein drink', 'whey protein'],
    '프로틴쉐이크': ['protein shake', 'protein drink', 'whey protein'],
    '단백질 쉐이크': ['protein shake', 'protein drink', 'whey protein'],
    '단백질쉐이크': ['protein shake', 'protein drink', 'whey protein'],
    '단백질 보충제': ['protein supplement', 'whey protein', 'protein powder'],
    '단백질보충제': ['protein supplement', 'whey protein', 'protein powder'],
    '프로틴 파우더': ['protein powder', 'whey protein'],
    '프로틴파우더': ['protein powder', 'whey protein'],
    '웨이 프로틴': ['whey protein', 'protein powder'],
    '웨이프로틴': ['whey protein', 'protein powder'],
    '우유': ['milk'],
    '치즈': ['cheese'],
    '요거트': ['yogurt'],
    '요구르트': ['yogurt'],
    '오트밀': ['oatmeal', 'oats'],
    '커피': ['coffee'],
    '주스': ['juice'],
    '감자튀김': ['french fries', 'fries'],
    '햄버거': ['burger', 'hamburger'],
    '피자': ['pizza'],
    '파스타': ['pasta'],
    '샐러드': ['salad'],
    '도넛': ['donut', 'doughnut'],
    '초콜릿': ['chocolate'],
    '아이스크림': ['ice cream'],
    '술': ['alcohol', 'liquor', 'beer', 'wine', 'soju'],
    '소주': ['soju'],
    '맥주': ['beer', 'lager'],
    '와인': ['wine'],
    '막걸리': ['makgeolli', 'rice wine'],
    '위스키': ['whiskey', 'whisky'],
    '하이볼': ['highball'],
  };

  final _koreanService = KoreanFoodService();

  /// 한글 포함 여부로 API 선택
  /// - 한글: 식품안전처 우선 → 결과 없으면 USDA fallback
  /// - 영문: USDA 검색
  Future<List<FoodModel>> searchFoods(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return [];

    if (_containsKorean(normalizedQuery)) {
      return _searchKorean(normalizedQuery);
    }

    final usdaResults = await _searchUsda(normalizedQuery);
    return _prependStandardizedResults(normalizedQuery, usdaResults);
  }

  Future<List<FoodModel>> _searchKorean(String query) async {
    final standardized = _prependStandardizedResults(query, const []);
    final merged = <FoodModel>[...standardized];
    final seen = <String>{};
    for (final food in merged) {
      seen.add('${food.source}:${food.name}');
    }

    for (final variant in _buildKoreanQueryVariants(query)) {
      final results = await _koreanService.searchKoreanFoods(variant);
      for (final food in _rankFoods(results, query)) {
        final key = '${food.source}:${food.name}';
        if (seen.add(key)) {
          merged.add(food);
        }
      }

      if (merged.length > standardized.length) {
        return merged;
      }
    }

    for (final alias in _buildEnglishAliases(query)) {
      final results = await _searchUsda(alias);
      for (final food in _rankFoods(
        _prependStandardizedResults(query, results),
        alias,
      )) {
        final key = '${food.source}:${food.name}';
        if (seen.add(key)) {
          merged.add(food);
        }
      }
      if (merged.length > standardized.length) {
        return merged;
      }
    }

    return merged;
  }

  Future<List<FoodModel>> _searchUsda(String query) async {
    try {
      final uri = Uri.parse('$_usdaBase/foods/search').replace(
        queryParameters: {
          'query': query,
          'api_key': _usdaKey,
          'dataType': 'Foundation,SR Legacy,Branded',
          'pageSize': '20',
        },
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final foods = json['foods'] as List<dynamic>? ?? [];
      return foods
          .map((f) => FoodModel.fromUsda(f as Map<String, dynamic>))
          .where((f) => f.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<FoodModel> _prependStandardizedResults(
    String query,
    List<FoodModel> results,
  ) {
    final standardized = <FoodModel>[
      ..._standardizedAlcoholResults(query),
      if (_isProteinQuery(query)) _standardProteinShake,
    ];
    if (standardized.isEmpty) return results;

    final merged = <FoodModel>[
      ...standardized,
      ...results,
    ];

    final seen = <String>{};
    return merged.where((food) => seen.add('${food.source}:${food.name}')).toList();
  }

  List<String> _buildKoreanQueryVariants(String query) {
    final collapsed = query.replaceAll(RegExp(r'\s+'), ' ').trim();
    final compact = collapsed.replaceAll(' ', '');
    final cleaned = compact.replaceAll(RegExp(r'[^\uAC00-\uD7A3A-Za-z0-9]'), '');
    final tokens = collapsed
        .split(' ')
        .map((token) => token.trim())
        .where((token) => token.length >= 2);

    final variants = <String>[
      collapsed,
      compact,
      cleaned,
      ...tokens,
    ];

    final unique = <String>{};
    return variants
        .where((variant) => variant.isNotEmpty && unique.add(variant))
        .toList();
  }

  List<String> _buildEnglishAliases(String query) {
    final aliases = <String>[];
    for (final entry in _koreanToEnglishAliases.entries) {
      if (query.contains(entry.key)) {
        aliases.addAll(entry.value);
      }
    }

    final unique = <String>{};
    if (query.contains('프로틴') || query.contains('단백질')) {
      aliases.addAll(['protein shake', 'whey protein', 'protein supplement']);
    }
    return aliases.where((alias) => unique.add(alias)).toList();
  }

  List<FoodModel> _rankFoods(List<FoodModel> foods, String originalQuery) {
    final compactQuery = originalQuery.replaceAll(RegExp(r'\s+'), '');
    final ranked = [...foods];

    ranked.sort((a, b) {
      final aScore = _matchScore(a.name, originalQuery, compactQuery);
      final bScore = _matchScore(b.name, originalQuery, compactQuery);
      if (aScore != bScore) return bScore.compareTo(aScore);
      return a.name.length.compareTo(b.name.length);
    });

    return ranked;
  }

  int _matchScore(String name, String originalQuery, String compactQuery) {
    final compactName = name.replaceAll(RegExp(r'\s+'), '');

    if (compactName == compactQuery) return 4;
    if (name == originalQuery) return 3;
    if (compactName.contains(compactQuery)) return 2;
    if (name.contains(originalQuery)) return 1;
    return 0;
  }

  bool _containsKorean(String text) {
    return text.runes.any((r) => r >= 0xAC00 && r <= 0xD7A3);
  }

  bool _isProteinQuery(String query) {
    final lower = query.toLowerCase();
    return lower.contains('protein') ||
        lower.contains('whey') ||
        lower.contains('shake') ||
        query.contains('프로틴') ||
        query.contains('단백질') ||
        query.contains('보충제');
  }

  bool _isAlcoholQuery(String query) {
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

  List<FoodModel> _standardizedAlcoholResults(String query) {
    if (!_isAlcoholQuery(query)) return [];

    final normalized = query.toLowerCase().replaceAll(' ', '');
    final catalog = <(List<String>, FoodModel)>[
      (
        ['술', '소주', 'soju'],
        const FoodModel(
          id: 'standard_soju',
          name: '소주',
          source: 'standard',
          nutritionBasisLabel: '100ml',
          per100g: FoodNutrition(
            calories: 130,
            carbsG: 0.8,
            proteinG: 0,
            fatG: 0,
            sugarG: 0,
            fiberG: 0,
            sodiumMg: 1,
            caffeineMg: 0,
            alcoholG: 17,
          ),
        ),
      ),
      (
        ['술', '맥주', 'beer', 'lager'],
        const FoodModel(
          id: 'standard_beer',
          name: '맥주',
          source: 'standard',
          nutritionBasisLabel: '100ml',
          per100g: FoodNutrition(
            calories: 43,
            carbsG: 3.6,
            proteinG: 0.4,
            fatG: 0,
            sugarG: 0.3,
            fiberG: 0,
            sodiumMg: 4,
            caffeineMg: 0,
            alcoholG: 4.3,
          ),
        ),
      ),
      (
        ['술', '와인', 'wine'],
        const FoodModel(
          id: 'standard_wine',
          name: '와인',
          source: 'standard',
          nutritionBasisLabel: '100ml',
          per100g: FoodNutrition(
            calories: 85,
            carbsG: 2.6,
            proteinG: 0.1,
            fatG: 0,
            sugarG: 0.8,
            fiberG: 0,
            sodiumMg: 5,
            caffeineMg: 0,
            alcoholG: 10.5,
          ),
        ),
      ),
      (
        ['술', '막걸리', 'makgeolli', 'ricewine'],
        const FoodModel(
          id: 'standard_makgeolli',
          name: '막걸리',
          source: 'standard',
          nutritionBasisLabel: '100ml',
          per100g: FoodNutrition(
            calories: 70,
            carbsG: 11,
            proteinG: 1.5,
            fatG: 0.2,
            sugarG: 2.5,
            fiberG: 0,
            sodiumMg: 6,
            caffeineMg: 0,
            alcoholG: 6,
          ),
        ),
      ),
      (
        ['술', '위스키', 'whiskey', 'whisky'],
        const FoodModel(
          id: 'standard_whiskey',
          name: '위스키',
          source: 'standard',
          nutritionBasisLabel: '100ml',
          per100g: FoodNutrition(
            calories: 250,
            carbsG: 0.1,
            proteinG: 0,
            fatG: 0,
            sugarG: 0,
            fiberG: 0,
            sodiumMg: 0,
            caffeineMg: 0,
            alcoholG: 40,
          ),
        ),
      ),
      (
        ['술', '하이볼', 'highball'],
        const FoodModel(
          id: 'standard_highball',
          name: '하이볼',
          source: 'standard',
          nutritionBasisLabel: '100ml',
          per100g: FoodNutrition(
            calories: 75,
            carbsG: 3,
            proteinG: 0,
            fatG: 0,
            sugarG: 2.5,
            fiberG: 0,
            sodiumMg: 3,
            caffeineMg: 0,
            alcoholG: 7,
          ),
        ),
      ),
    ];

    final matches = catalog
        .where((entry) => entry.$1.any((keyword) => normalized.contains(keyword)))
        .map((entry) => entry.$2)
        .toList();
    if (matches.isNotEmpty) return matches;

    if (normalized.contains('술') || normalized.contains('alcohol')) {
      return catalog.map((entry) => entry.$2).toList();
    }
    return [];
  }

  static const _standardProteinShake = FoodModel(
    id: 'standard_protein_shake',
    name: '프로틴 쉐이크',
    source: 'standard',
    nutritionBasisLabel: '100g',
    per100g: FoodNutrition(
      calories: 380,
      carbsG: 12,
      proteinG: 75,
      fatG: 6,
      sugarG: 5,
      fiberG: 1,
      sodiumMg: 220,
      caffeineMg: 0,
      alcoholG: 0,
    ),
  );
}
