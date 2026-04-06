/// 음식 이름 키워드 → 일반적인 1회 섭취 단위 매핑
class PortionOption {
  final String label; // "1조각 (30g)"
  final double grams;

  const PortionOption(this.label, this.grams);
}

class PortionHelper {
  static const _map = <String, List<PortionOption>>{
    // ── 곡류 ─────────────────────────────
    'rice|밥|쌀': [
      PortionOption('1공기 (210g)', 210),
      PortionOption('반공기 (105g)', 105),
      PortionOption('1/3공기 (70g)', 70),
    ],
    'bread|빵|toast|토스트': [
      PortionOption('1조각 (30g)', 30),
      PortionOption('2조각 (60g)', 60),
      PortionOption('3조각 (90g)', 90),
    ],
    'noodle|pasta|면|라면|국수|파스타': [
      PortionOption('1인분 (100g 건면)', 100),
      PortionOption('1인분 (200g 조리 후)', 200),
    ],
    'oat|오트밀': [
      PortionOption('1회분 (40g 건)', 40),
      PortionOption('1회분 (80g 조리 후)', 80),
    ],
    // ── 단백질 ──────────────────────────
    'egg|계란|달걀': [
      PortionOption('1개 소 (40g)', 40),
      PortionOption('1개 중 (50g)', 50),
      PortionOption('1개 대 (60g)', 60),
      PortionOption('2개 (100g)', 100),
    ],
    'chicken|닭|치킨': [
      PortionOption('1쪽 가슴살 (150g)', 150),
      PortionOption('1쪽 허벅지 (100g)', 100),
      PortionOption('1인분 (200g)', 200),
    ],
    'beef|소고기|스테이크': [
      PortionOption('1인분 (150g)', 150),
      PortionOption('1인분 (200g)', 200),
    ],
    'pork|돼지|삼겹살': [
      PortionOption('1인분 (150g)', 150),
      PortionOption('1인분 (200g)', 200),
    ],
    'fish|생선|연어|참치|salmon|tuna': [
      PortionOption('1토막 (100g)', 100),
      PortionOption('1토막 (150g)', 150),
    ],
    // ── 유제품 ──────────────────────────
    'milk|우유': [
      PortionOption('1컵 (200ml)', 200),
      PortionOption('반컵 (100ml)', 100),
    ],
    'yogurt|요거트|요구르트': [
      PortionOption('1개 소 (100g)', 100),
      PortionOption('1개 대 (200g)', 200),
    ],
    'cheese|치즈': [
      PortionOption('1장 (20g)', 20),
      PortionOption('2장 (40g)', 40),
    ],
    // ── 과일 ────────────────────────────
    'banana|바나나': [
      PortionOption('1개 소 (80g)', 80),
      PortionOption('1개 중 (100g)', 100),
      PortionOption('1개 대 (120g)', 120),
    ],
    'apple|사과': [
      PortionOption('1개 소 (150g)', 150),
      PortionOption('1개 중 (200g)', 200),
      PortionOption('반개 (100g)', 100),
    ],
    'orange|귤|오렌지': [
      PortionOption('1개 (100g)', 100),
      PortionOption('1개 (150g)', 150),
    ],
    // ── 채소 ────────────────────────────
    'salad|샐러드': [
      PortionOption('1접시 (100g)', 100),
      PortionOption('1접시 (150g)', 150),
    ],
    // ── 음료 ────────────────────────────
    'coffee|커피|아메리카노|라떼': [
      PortionOption('1잔 Small (240ml)', 240),
      PortionOption('1잔 Grande (355ml)', 355),
      PortionOption('1잔 Venti (473ml)', 473),
    ],
    'juice|주스': [
      PortionOption('1컵 (200ml)', 200),
      PortionOption('1병 (350ml)', 350),
    ],
  };

  /// 음식 이름에 맞는 기본 섭취량 목록 반환
  /// 없으면 빈 리스트 (→ 직접 입력만 제공)
  static List<PortionOption> getPortions(String foodName) {
    final lower = foodName.toLowerCase();
    for (final entry in _map.entries) {
      final keywords = entry.key.split('|');
      if (keywords.any((kw) => lower.contains(kw))) {
        return entry.value;
      }
    }
    return [];
  }
}
