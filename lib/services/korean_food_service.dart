import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrient_tracker/data/food_aliases.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/services/food_cache_service.dart';

class KoreanFoodService {
  static String get _apiKey => (dotenv.env['DATA_API_KEY'] ?? '').trim();
  static String get _mfdsApiKey =>
      (dotenv.env['MFDS_API_KEY'] ?? dotenv.env['DATA_API_KEY'] ?? '').trim();
  static const _mfdsFoodDbUrl =
      'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02';

  static const _apis = [
    ('nutri', 'https://api.data.go.kr/openapi/tn_pubr_public_nutri_info_api', 'foodNm'),
    ('food', 'https://api.data.go.kr/openapi/tn_pubr_public_nutri_food_info_api', 'foodNm'),
    ('material', 'https://api.data.go.kr/openapi/tn_pubr_public_nutri_material_info_api', 'prdlstNm'),
    ('process', 'https://api.data.go.kr/openapi/tn_pubr_public_nutri_process_info_api', 'prdlstNm'),
    ('health', 'https://api.data.go.kr/openapi/tn_pubr_public_health_functional_food_nutrition_info_api', 'hfoodNm'),
  ];

  Future<List<FoodModel>> searchKoreanFoods(String query) async {
    if (query.trim().isEmpty) return [];

    // 1단계: Supabase 캐시 조회
    final cached = await FoodCacheService.search(query);
    if (cached.isNotEmpty) {
      debugPrint('✅ [cache] ${cached.length}개 캐시 히트');
      return cached;
    }

    // 2단계: 외부 API 호출
    final key = _apiKey;
    debugPrint('🔑 apiKey=${key.isEmpty ? "비어있음!" : "${key.substring(0, 8)}..."}');
    if (key.isEmpty) return [];

    final futures = <Future<List<FoodModel>>>[
      _fetchMfdsFoodDb(query),
      ..._apis.map((api) {
        final (source, url, queryParam) = api;
        return _fetchOne(url: url, source: source, queryParam: queryParam, query: query);
      }),
    ];

    final results = await Future.wait(futures);
    final seen = <String>{};
    final unique = results
        .expand((r) => r)
        .where((f) => f.name.isNotEmpty)
        .where(_hasUsableNutrition)
        .where((f) => seen.add('${f.source}:${f.id}:${f.name}:${f.nutritionBasisLabel}'))
        .toList();

    debugPrint('🍱 총 ${unique.length}개 결과 → 캐시 저장 중');
    // 3단계: 결과를 캐시에 저장 (다음 검색부터 빠르게)
    FoodCacheService.saveAll(unique);
    return unique;
  }

  Future<List<FoodModel>> searchBrandedFoods(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return [];

    // 캐시에서 브랜드 식품 먼저 확인
    final cached = await FoodCacheService.search(normalized);
    final cachedBranded = cached.where((f) => f.isBrandedProduct).toList();
    if (cachedBranded.isNotEmpty) return cachedBranded;

    final makerCandidates = <String>{..._resolveMakerCandidates(normalized)};
    final futures = <Future<List<FoodModel>>>[
      _fetchMfdsFoodDb(normalized),
      ...makerCandidates.map((maker) => _fetchMfdsFoodDb(normalized, makerName: maker)),
    ];

    final results = await Future.wait(futures);
    final seen = <String>{};
    final branded = results
        .expand((rows) => rows)
        .where((food) => food.isBrandedProduct)
        .where((food) => _isRelevantBrandedResult(food, normalized))
        .where((food) => seen.add('${food.id}:${food.name}:${food.makerName ?? ''}'))
        .toList();

    FoodCacheService.saveAll(branded);
    return branded;
  }

  Future<List<FoodModel>> _fetchOne({
    required String url,
    required String source,
    required String queryParam,
    required String query,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: {
        'serviceKey': _apiKey,
        'pageNo': '1',
        'numOfRows': '20',
        'type': 'json',
        queryParam: query,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final code = json['response']?['header']?['resultCode'] as String? ?? '';
      if (!code.startsWith('0')) return [];

      final rawItems = json['response']?['body']?['items'];
      if (rawItems == null) return [];
      final List<dynamic> items = rawItems is List ? rawItems : [rawItems];

      return items
          .map((item) => FoodModel.fromDataGovKr(item as Map<String, dynamic>, source))
          .where((f) => f.name.isNotEmpty)
          .where(_hasUsableNutrition)
          .toList();
    } catch (e) {
      debugPrint('💥 [$source] 예외: $e');
      return [];
    }
  }

  Future<List<FoodModel>> _fetchMfdsFoodDb(String query, {String? makerName}) async {
    final key = _mfdsApiKey;
    if (key.isEmpty) return [];
    try {
      final uri = Uri.parse(_mfdsFoodDbUrl).replace(queryParameters: {
        'serviceKey': key,
        'pageNo': '1',
        'numOfRows': '20',
        'type': 'json',
        'FOOD_NM_KR': query,
        if (makerName != null && makerName.isNotEmpty) 'MAKER_NM': makerName,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return [];
      if (response.body.trim().toLowerCase() == 'unauthorized') return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final header = json['header'] ?? json['response']?['header'];
      final code = header?['resultCode'] as String? ?? '';
      if (code.isNotEmpty && !code.startsWith('0')) return [];

      final body = json['body'] ?? json['response']?['body'];
      final rawItems = body?['items'] ?? body?['item'];
      if (rawItems == null) return [];
      final List<dynamic> items = rawItems is List ? rawItems : [rawItems];

      return items
          .map((item) => FoodModel.fromMfds(item as Map<String, dynamic>))
          .where((f) => f.name.isNotEmpty)
          .where(_hasUsableNutrition)
          .toList();
    } catch (e) {
      debugPrint('💥 [mfds_food_db] 예외: $e');
      return [];
    }
  }

  bool _hasUsableNutrition(FoodModel f) {
    final n = f.per100g;
    return n.calories > 0 || n.carbsG > 0 || n.proteinG > 0 || n.fatG > 0 ||
        n.sugarG > 0 || n.fiberG > 0 || n.sodiumMg > 0 ||
        n.caffeineMg > 0 || n.alcoholG > 0;
  }

  Iterable<String> _resolveMakerCandidates(String query) sync* {
    for (final entry in brandMakerAliases.entries) {
      if (query.contains(entry.key)) yield* entry.value;
    }
  }

  bool _isRelevantBrandedResult(FoodModel food, String query) {
    final q = _normalize(query);
    final n = _normalize(food.name);
    if (n.contains(q) || q.contains(n)) return true;
    if (food.makerName != null && food.makerName!.isNotEmpty) {
      if (_normalize(food.makerName!).contains(q)) return true;
    }
    return false;
  }

  String _normalize(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[^0-9a-z가-힣]+'), '');
}
