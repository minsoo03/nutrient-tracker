// 약물-영양소 상호작용 경고 데이터
// 향후 식약처 의약품 안전나라 API 연동 예정
// API: https://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService04


class MedicineWarning {
  final String title;
  final String description;
  final String nutrient; // 관련 영양소 키

  const MedicineWarning({
    required this.title,
    required this.description,
    required this.nutrient,
  });
}

class MedicationRiskProfile {
  final String category;
  final double liverWeight;
  final double kidneyWeight;
  final bool sensitiveToProtein;
  final bool sensitiveToAlcohol;
  final bool sensitiveToCaffeine;

  const MedicationRiskProfile({
    required this.category,
    this.liverWeight = 0,
    this.kidneyWeight = 0,
    this.sensitiveToProtein = false,
    this.sensitiveToAlcohol = false,
    this.sensitiveToCaffeine = false,
  });
}

const kMedicineWarnings = <String, List<MedicineWarning>>{
  '항응고제': [
    MedicineWarning(
      title: '비타민K 주의',
      description: '와파린 복용 중 시금치, 브로콜리 등 비타민K 함량 높은 식품 과다 섭취 주의',
      nutrient: 'vitaminK',
    ),
  ],
  '이뇨제': [
    MedicineWarning(
      title: '칼륨 보충 필요',
      description: '루프 이뇨제 복용 시 칼륨 손실 증가. 바나나, 감자 등 칼륨 식품 섭취 권장',
      nutrient: 'potassiumMg',
    ),
    MedicineWarning(
      title: '나트륨 제한',
      description: '나트륨 과다 섭취 시 이뇨제 효과 감소',
      nutrient: 'sodiumMg',
    ),
  ],
  'ACE억제제': [
    MedicineWarning(
      title: '칼륨 과다 주의',
      description: '칼륨 보유 효과로 칼륨 과다 섭취 시 고칼륨혈증 위험',
      nutrient: 'potassiumMg',
    ),
  ],
  '스타틴(고지혈증약)': [
    MedicineWarning(
      title: '자몽 주의',
      description: '자몽즙이 스타틴 대사를 방해하여 부작용 증가 가능',
      nutrient: 'fat',
    ),
  ],
  'MAO억제제(항우울제)': [
    MedicineWarning(
      title: '티라민 식품 주의',
      description: '치즈, 청어, 발효식품 등 티라민 함유 식품 섭취 금지. 고혈압 위기 위험',
      nutrient: 'proteinG',
    ),
  ],
  '철분제': [
    MedicineWarning(
      title: '칼슘·카페인 분리 복용',
      description: '철분 흡수를 방해. 복용 2시간 전후로 유제품, 커피 섭취 피할 것',
      nutrient: 'caffeineMg',
    ),
  ],
  '신장 투석': [
    MedicineWarning(
      title: '단백질·칼륨·인 엄격 제한',
      description: '단백질 0.6~0.8g/kg, 칼륨 2000mg 이하, 인 800mg 이하 유지 필요',
      nutrient: 'proteinG',
    ),
  ],
  '피부과약(이소트레티노인 등)': [
    MedicineWarning(
      title: '간 부담 주의',
      description: '음주, 고용량 보충제, 고지방 식사와 함께 복용 시 간 부담이 커질 수 있음',
      nutrient: 'alcoholG',
    ),
    MedicineWarning(
      title: '보충제 과다 주의',
      description: '고단백 보충제나 복합 영양제 과다 섭취는 피하는 것이 좋음',
      nutrient: 'proteinG',
    ),
  ],
  '소염진통제(NSAIDs)': [
    MedicineWarning(
      title: '신장 부담 주의',
      description: '탈수 상태, 고단백 보충제, 음주와 겹치면 신장 부담이 커질 수 있음',
      nutrient: 'proteinG',
    ),
  ],
};


const kAcuteCategories = <String>[
  '감기약',
  '진통제',
  '해열제',
  '항생제',
  '알레르기약',
  '소화제',
  '기침약',
];
