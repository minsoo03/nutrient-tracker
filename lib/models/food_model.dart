import 'package:nutrient_tracker/models/food_nutrition.dart';

export 'package:nutrient_tracker/models/food_nutrition.dart' show FoodNutrition;

class FoodModel {
  final String id;
  final String name;
  final String? nameEn;
  final String source;
  final FoodNutrition per100g;
  final String nutritionBasisLabel;
  final double? packageAmount;
  final String? packageUnit;
  final int variantCount; // 1=단일, >1=N종 평균값

  const FoodModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.source,
    required this.per100g,
    this.nutritionBasisLabel = '100g',
    this.packageAmount,
    this.packageUnit,
    this.variantCount = 1,
  });

  String get displayBasisLabel => '$nutritionBasisLabel 기준';

  String? get packageCaloriesSummary {
    if (packageAmount == null || packageUnit == null) return null;
    if (packageUnit != 'g' && packageUnit != 'ml') return null;

    final totalCalories = per100g.scaled(packageAmount!).calories;
    final amountLabel = packageAmount! % 1 == 0
        ? packageAmount!.toStringAsFixed(0)
        : packageAmount!.toStringAsFixed(1);
    return '총 $amountLabel${packageUnit!} 약 ${totalCalories.toStringAsFixed(0)} kcal';
  }

  /// 식품안전처 I2790 응답 파싱
  factory FoodModel.fromMfds(Map<String, dynamic> json) {
    double parseDouble(String key) =>
        double.tryParse(json[key]?.toString() ?? '0') ?? 0.0;

    final name = cleanFoodName(json['FOOD_NM_KR']);

    return FoodModel(
      id: 'mfds_${json['FOOD_CD'] ?? name}',
      name: name,
      source: 'kr_mfds',
      nutritionBasisLabel: '100g',
      per100g: FoodNutrition(
        calories: parseDouble('ENERC'),
        carbsG: parseDouble('CHOC'),
        proteinG: parseDouble('PROT'),
        fatG: parseDouble('FAT'),
        sugarG: parseDouble('SUGAR'),
        fiberG: parseDouble('FIBT'),
        sodiumMg: parseDouble('NA'),
        caffeineMg: parseDouble('CAFFN'),
        alcoholG: parseDouble('ALCOHOL'),
      ),
    );
  }

  /// 공공데이터포털 (data.go.kr) 통합 파서
  factory FoodModel.fromDataGovKr(Map<String, dynamic> json, String source) {
    double pickValue(List<String> keys) {
      for (final k in keys) {
        final v = double.tryParse(json[k]?.toString() ?? '');
        if (v != null && v > 0) return v;
      }
      return 0.0;
    }

    final basisLabel =
        (json['nutConSrtrQua']?.toString().trim().isNotEmpty ?? false)
        ? json['nutConSrtrQua'].toString().trim()
        : '100g';
    final basisInfo = _parseAmountAndUnit(basisLabel);
    final normalizationFactor =
        basisInfo != null &&
            (basisInfo.$2 == 'g' || basisInfo.$2 == 'ml') &&
            basisInfo.$1 > 0
        ? 100.0 / basisInfo.$1
        : 1.0;
    final packageInfo = _parseAmountAndUnit(json['foodSize']?.toString());

    final name = cleanFoodName(
      json['foodNm'] ??
          json['prdlstNm'] ??
          json['hfoodNm'] ??
          json['FOOD_NM'] ??
          json['PRDLST_NM'] ??
          json['HFOOD_NM'],
    );
    final code =
        (json['foodCd'] ?? json['prdlstReportNo'] ?? json['hfoodCd'] ?? name)
            .toString();
    final caffeineValue = pickValue(['caffn', 'caffeine']);
    final fallbackCaffeine = _fallbackCaffeinePer100(name);

    return FoodModel(
      id: '${source}_$code',
      name: name,
      source: source,
      nutritionBasisLabel: basisLabel,
      packageAmount: packageInfo?.$1,
      packageUnit: packageInfo?.$2,
      per100g: FoodNutrition(
        calories:
            pickValue(['enerc', 'ENERC', 'calorie', 'CALORIE', 'amtNum1']) *
            normalizationFactor,
        carbsG:
            pickValue(['chocdf', 'CHOCDF', 'carbs', 'CARBS', 'amtNum6']) *
            normalizationFactor,
        proteinG:
            pickValue(['prot', 'PROT', 'protein', 'PROTEIN', 'amtNum3']) *
            normalizationFactor,
        fatG:
            pickValue(['fatce', 'FATCE', 'fat', 'FAT', 'amtNum4']) *
            normalizationFactor,
        sugarG: pickValue(['sugar', 'SUGAR', 'amtNum7']) * normalizationFactor,
        fiberG:
            pickValue(['fibtg', 'FIBTG', 'dietaryFiber', 'amtNum8']) *
            normalizationFactor,
        sodiumMg:
            pickValue(['nat', 'NAT', 'sodium', 'SODIUM', 'amtNum13']) *
            normalizationFactor,
        caffeineMg:
            (caffeineValue > 0 ? caffeineValue : fallbackCaffeine) *
            normalizationFactor,
        alcoholG:
            pickValue(['alcohol', 'alc', 'alcoholG']) * normalizationFactor,
      ),
    );
  }

  factory FoodModel.fromUsda(Map<String, dynamic> json) {
    double nutrientValue(int nutrientId) {
      final nutrients = json['foodNutrients'] as List<dynamic>? ?? [];
      for (final n in nutrients) {
        if (n['nutrientId'] == nutrientId) {
          return (n['value'] ?? 0.0).toDouble();
        }
      }
      return 0.0;
    }

    return FoodModel(
      id: 'usda_${json['fdcId']}',
      name: cleanFoodName(json['description']),
      nameEn: json['description'],
      source: 'usda',
      nutritionBasisLabel: '100g',
      per100g: FoodNutrition(
        calories: nutrientValue(1008),
        carbsG: nutrientValue(1005),
        proteinG: nutrientValue(1003),
        fatG: nutrientValue(1004),
        sugarG: nutrientValue(2000),
        fiberG: nutrientValue(1079),
        sodiumMg: nutrientValue(1093),
        caffeineMg: nutrientValue(1057),
        alcoholG: nutrientValue(1018),
      ),
    );
  }

  static (double, String)? _parseAmountAndUnit(String? raw) {
    if (raw == null) return null;
    final text = raw.trim().toLowerCase();
    if (text.isEmpty) return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*(g|ml)').firstMatch(text);
    if (match == null) return null;
    final amount = double.tryParse(match.group(1)!);
    final unit = match.group(2);
    if (amount == null || unit == null) return null;
    return (amount, unit);
  }

  static String cleanFoodName(dynamic raw) {
    final text = (raw ?? '').toString().trim();
    if (text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'[@]+'), ' ')
        .replaceAll(RegExp(r'[_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static double _fallbackCaffeinePer100(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('에너지드링크') ||
        lower.contains('energy drink') ||
        lower.contains('energydrink') ||
        lower.contains('monster') ||
        lower.contains('red bull') ||
        lower.contains('redbull') ||
        lower.contains('핫식스')) {
      return 30.0;
    }
    if (lower.contains('콜라') ||
        lower.contains('cola') ||
        lower.contains('coke') ||
        lower.contains('코카콜라') ||
        lower.contains('펩시') ||
        lower.contains('pepsi')) {
      return 10.0;
    }
    return 0.0;
  }
}
