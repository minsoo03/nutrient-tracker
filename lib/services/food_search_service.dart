import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/services/korean_food_service.dart';

class FoodSearchService {
  static const _usdaBase = 'https://api.nal.usda.gov/fdc/v1';
  static const _usdaKey = 'DEMO_KEY'; // 실 서비스 시 교체 필요

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

    return _searchUsda(normalizedQuery);
  }

  Future<List<FoodModel>> _searchKorean(String query) async {
    final merged = <FoodModel>[];
    final seen = <String>{};

    for (final variant in _buildKoreanQueryVariants(query)) {
      final results = await _koreanService.searchKoreanFoods(variant);
      for (final food in _rankFoods(results, query)) {
        final key = '${food.source}:${food.name}';
        if (seen.add(key)) {
          merged.add(food);
        }
      }

      if (merged.isNotEmpty) {
        return merged;
      }
    }

    return [];
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
}
