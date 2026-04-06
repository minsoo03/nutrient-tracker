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
    if (query.trim().isEmpty) return [];

    if (_containsKorean(query)) {
      final krResults = await _koreanService.searchKoreanFoods(query);
      if (krResults.isNotEmpty) return krResults;
      // 한글 검색 실패 시 영문 변환 없이 빈 결과 + 안내
      return [];
    }

    return _searchUsda(query);
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

  bool _containsKorean(String text) {
    return text.runes.any((r) => r >= 0xAC00 && r <= 0xD7A3);
  }
}
