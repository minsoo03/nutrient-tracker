class FoodNutrition {
  final double calories;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double sugarG;
  final double fiberG;
  final double sodiumMg;
  final double caffeineMg;

  const FoodNutrition({
    required this.calories,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.sugarG,
    required this.fiberG,
    required this.sodiumMg,
    required this.caffeineMg,
  });

  FoodNutrition scaled(double grams) {
    final ratio = grams / 100.0;
    return FoodNutrition(
      calories: calories * ratio,
      carbsG: carbsG * ratio,
      proteinG: proteinG * ratio,
      fatG: fatG * ratio,
      sugarG: sugarG * ratio,
      fiberG: fiberG * ratio,
      sodiumMg: sodiumMg * ratio,
      caffeineMg: caffeineMg * ratio,
    );
  }
}

class FoodModel {
  final String id;
  final String name;
  final String? nameEn;
  final String source;
  final FoodNutrition per100g;
  final int variantCount; // 1=단일, >1=N종 평균값

  const FoodModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.source,
    required this.per100g,
    this.variantCount = 1,
  });

  /// 식품안전처 I2790 응답 파싱
  /// 주요 필드: FOOD_NM_KR, ENERC(kcal), PROT(g), FAT(g), CHOC(g),
  ///           SUGAR(g), FIBT(g), NA(mg), CAFFN(mg)
  factory FoodModel.fromMfds(Map<String, dynamic> json) {
    double parseDouble(String key) =>
        double.tryParse(json[key]?.toString() ?? '0') ?? 0.0;

    return FoodModel(
      id: 'mfds_${json['FOOD_CD'] ?? json['FOOD_NM_KR']}',
      name: json['FOOD_NM_KR'] ?? '',
      source: 'kr_mfds',
      per100g: FoodNutrition(
        calories: parseDouble('ENERC'),
        carbsG: parseDouble('CHOC'),
        proteinG: parseDouble('PROT'),
        fatG: parseDouble('FAT'),
        sugarG: parseDouble('SUGAR'),
        fiberG: parseDouble('FIBT'),
        sodiumMg: parseDouble('NA'),
        caffeineMg: parseDouble('CAFFN'),
      ),
    );
  }

  /// 공공데이터포털 (data.go.kr) 음식·원재료·가공식품·건강기능식품 통합 파서
  /// 각 API별 필드명이 조금씩 다르므로 fallback 키 목록으로 처리
  factory FoodModel.fromDataGovKr(Map<String, dynamic> json, String source) {
    double pickValue(List<String> keys) {
      for (final k in keys) {
        final v = double.tryParse(json[k]?.toString() ?? '');
        if (v != null && v > 0) return v;
      }
      return 0.0;
    }

    final name = (json['foodNm'] ?? json['prdlstNm'] ?? json['hfoodNm'] ?? '').toString();
    final code = (json['foodCd'] ?? json['prdlstReportNo'] ?? json['hfoodCd'] ?? name).toString();

    return FoodModel(
      id: '${source}_$code',
      name: name,
      source: source,
      per100g: FoodNutrition(
        calories: pickValue(['enerc', 'calorie', 'amtNum1']),
        carbsG: pickValue(['chocdf', 'carbs', 'amtNum6']),
        proteinG: pickValue(['prot', 'protein', 'amtNum3']),
        fatG: pickValue(['fatce', 'fat', 'amtNum4']),
        sugarG: pickValue(['sugar', 'amtNum7']),
        fiberG: pickValue(['fibtg', 'dietaryFiber', 'amtNum8']),
        sodiumMg: pickValue(['nat', 'sodium', 'amtNum13']),
        caffeineMg: pickValue(['caffn', 'caffeine']),
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
      name: json['description'] ?? '',
      nameEn: json['description'],
      source: 'usda',
      per100g: FoodNutrition(
        calories: nutrientValue(1008),
        carbsG: nutrientValue(1005),
        proteinG: nutrientValue(1003),
        fatG: nutrientValue(1004),
        sugarG: nutrientValue(2000),
        fiberG: nutrientValue(1079),
        sodiumMg: nutrientValue(1093),
        caffeineMg: nutrientValue(1057),
      ),
    );
  }
}
