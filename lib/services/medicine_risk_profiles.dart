import 'package:nutrient_tracker/services/medicine_data.dart';

const kMedicationRiskProfiles = <String, MedicationRiskProfile>{
  '신장 투석': MedicationRiskProfile(
    category: '신장 투석',
    kidneyWeight: 18,
    sensitiveToProtein: true,
  ),
  '피부과약(이소트레티노인 등)': MedicationRiskProfile(
    category: '피부과약(이소트레티노인 등)',
    liverWeight: 12,
    kidneyWeight: 2,
    sensitiveToProtein: true,
    sensitiveToAlcohol: true,
  ),
  '소염진통제(NSAIDs)': MedicationRiskProfile(
    category: '소염진통제(NSAIDs)',
    liverWeight: 4,
    kidneyWeight: 10,
    sensitiveToProtein: true,
    sensitiveToAlcohol: true,
  ),
  '이뇨제': MedicationRiskProfile(
    category: '이뇨제',
    kidneyWeight: 8,
    sensitiveToCaffeine: true,
  ),
  'ACE억제제': MedicationRiskProfile(
    category: 'ACE억제제',
    kidneyWeight: 6,
  ),
  '스타틴(고지혈증약)': MedicationRiskProfile(
    category: '스타틴(고지혈증약)',
    liverWeight: 6,
    sensitiveToAlcohol: true,
  ),
  // 상시 복용약 추가 프로파일
  '항응고제': MedicationRiskProfile(
    category: '항응고제',
    liverWeight: 4,
    sensitiveToAlcohol: true,
  ),
  'MAO억제제(항우울제)': MedicationRiskProfile(
    category: 'MAO억제제(항우울제)',
    liverWeight: 6,
    sensitiveToAlcohol: true,
    sensitiveToCaffeine: true,
  ),
  '철분제': MedicationRiskProfile(
    category: '철분제',
    liverWeight: 2,
    sensitiveToCaffeine: true,
  ),
  // 단기 복용약 (간·신장 부담 있는 성분 포함)
  '진통제': MedicationRiskProfile(
    category: '진통제',
    liverWeight: 4,
    kidneyWeight: 5,
    sensitiveToAlcohol: true,
    sensitiveToProtein: true,
  ),
  '해열제': MedicationRiskProfile(
    category: '해열제',
    liverWeight: 5,
    kidneyWeight: 2,
    sensitiveToAlcohol: true,
  ),
  '감기약': MedicationRiskProfile(
    category: '감기약',
    liverWeight: 3,
    kidneyWeight: 2,
    sensitiveToAlcohol: true,
  ),
  '항생제': MedicationRiskProfile(
    category: '항생제',
    liverWeight: 4,
    kidneyWeight: 3,
  ),
  '알레르기약': MedicationRiskProfile(
    category: '알레르기약',
    liverWeight: 1,
    sensitiveToCaffeine: true,
  ),
};
