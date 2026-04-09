import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrient_tracker/models/food_model.dart';

/// 공공데이터포털 한국 식품 영양성분 통합 검색 (5개 API 병렬 호출)
/// (source, endpoint, 검색파라미터명)
class KoreanFoodService {
  static String get _apiKey => (dotenv.env['DATA_API_KEY'] ?? '').trim();
  static String get _mfdsApiKey =>
      (dotenv.env['MFDS_API_KEY'] ?? dotenv.env['DATA_API_KEY'] ?? '').trim();
  static const _mfdsFoodDbUrl =
      'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02';

  static const _apis = [
    ('nutri',    'https://api.data.go.kr/openapi/tn_pubr_public_nutri_info_api',                                    'foodNm'),
    ('food',     'https://api.data.go.kr/openapi/tn_pubr_public_nutri_food_info_api',                               'foodNm'),
    ('material', 'https://api.data.go.kr/openapi/tn_pubr_public_nutri_material_info_api',                           'prdlstNm'),
    ('process',  'https://api.data.go.kr/openapi/tn_pubr_public_nutri_process_info_api',                            'prdlstNm'),
    ('health',   'https://api.data.go.kr/openapi/tn_pubr_public_health_functional_food_nutrition_info_api',         'hfoodNm'),
  ];

  Future<List<FoodModel>> searchKoreanFoods(String query) async {
    final key = _apiKey;
    debugPrint('🔑 apiKey=${key.isEmpty ? "비어있음!" : "${key.substring(0, 8)}..."}');
    if (key.isEmpty) return [];
    if (query.trim().isEmpty) return [];

    final futures = <Future<List<FoodModel>>>[
      _fetchMfdsFoodDb(query),
      ..._apis.map((api) {
      final (source, url, queryParam) = api;
      return _fetchOne(url: url, source: source, queryParam: queryParam, query: query);
      }),
    ];

    final results = await Future.wait(futures);
    final all = results.expand((r) => r).toList();
    debugPrint('🍱 총 ${all.length}개 결과');

    final seen = <String>{};
    return all
        .where((f) => f.name.isNotEmpty)
        .where(
          (f) => seen.add(
            '${f.source}:${f.id}:${f.name}:${f.nutritionBasisLabel}',
          ),
        )
        .toList();
  }

  Future<List<FoodModel>> _fetchOne({
    required String url,
    required String source,
    required String queryParam,
    required String query,
  }) async {
    try {
      // Uri.replace 사용 → Dart가 인코딩 자동 처리 (이중인코딩 방지)
      final uri = Uri.parse(url).replace(queryParameters: {
        'serviceKey': _apiKey,
        'pageNo':     '1',
        'numOfRows':  '20',
        'type':       'json',
        queryParam:   query,
      });

      debugPrint('📡 [$source] $queryParam=$query');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint('📡 [$source] status=${response.statusCode}');

      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final header = json['response']?['header'];
      final code   = header?['resultCode'] as String? ?? '';
      final msg    = header?['resultMsg']  as String? ?? '';

      if (!code.startsWith('0')) {
        debugPrint('❌ [$source] $code $msg');
        debugPrint('❌ [$source] 응답 전체: ${response.body.substring(0, response.body.length.clamp(0, 300))}');
        return [];
      }

      final rawItems = json['response']?['body']?['items'];
      if (rawItems == null) {
        debugPrint('⚠️  [$source] 결과 없음');
        return [];
      }

      final List<dynamic> items = rawItems is List ? rawItems : [rawItems];
      debugPrint('✅ [$source] ${items.length}개');

      return items
          .map((item) => FoodModel.fromDataGovKr(item as Map<String, dynamic>, source))
          .where((f) => f.name.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('💥 [$source] 예외: $e');
      return [];
    }
  }

  Future<List<FoodModel>> _fetchMfdsFoodDb(String query) async {
    final key = _mfdsApiKey;
    if (key.isEmpty) return [];

    try {
      final uri = Uri.parse(_mfdsFoodDbUrl).replace(queryParameters: {
        'serviceKey': key,
        'pageNo': '1',
        'numOfRows': '20',
        'type': 'json',
        'DESC_KOR': query,
      });

      debugPrint('📡 [mfds_food_db] DESC_KOR=$query');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint('📡 [mfds_food_db] status=${response.statusCode}');

      if (response.statusCode != 200) return [];
      if (response.body.trim().toLowerCase() == 'unauthorized') {
        debugPrint('❌ [mfds_food_db] Unauthorized');
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final header = json['header'] ?? json['response']?['header'];
      final code = header?['resultCode'] as String? ?? '';
      final msg = header?['resultMsg'] as String? ?? '';

      if (code.isNotEmpty && !code.startsWith('0')) {
        debugPrint('❌ [mfds_food_db] $code $msg');
        return [];
      }

      final body = json['body'] ?? json['response']?['body'];
      final rawItems = body?['items'] ?? body?['item'];
      if (rawItems == null) {
        debugPrint('⚠️  [mfds_food_db] 결과 없음');
        return [];
      }

      final List<dynamic> items = rawItems is List ? rawItems : [rawItems];
      debugPrint('✅ [mfds_food_db] ${items.length}개');

      return items
          .map((item) => FoodModel.fromMfds(item as Map<String, dynamic>))
          .where((f) => f.name.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('💥 [mfds_food_db] 예외: $e');
      return [];
    }
  }
}
