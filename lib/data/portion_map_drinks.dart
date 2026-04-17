import 'package:nutrient_tracker/data/portion_map.dart';

/// 음료/술 키워드 → 1회 섭취 단위 매핑
/// 음식 → portion_map.dart
const kPortionMapDrinks = <String, List<PortionOption>>{
  'coffee|커피|아메리카노|라떼|카푸치노|마끼아또': [
    PortionOption('Short 1잔 (240ml)', 240),
    PortionOption('Grande 1잔 (355ml)', 355),
    PortionOption('Venti 1잔 (473ml)', 473),
  ],
  'juice|주스': [
    PortionOption('1컵 (200ml)', 200), PortionOption('1병 (350ml)', 350),
  ],
  '에너지드링크|energy drink|monster|red bull|redbull|핫식스|박카스': [
    PortionOption('반 캔 (125ml)', 125), PortionOption('1캔 (250ml)', 250),
    PortionOption('큰 캔 (355ml)', 355), PortionOption('대용량 (500ml)', 500),
  ],
  'cola|coke|콜라|soda|탄산|사이다|sprite|fanta|pepsi': [
    PortionOption('반 캔 (125ml)', 125), PortionOption('1캔 (250ml)', 250),
    PortionOption('355ml 캔', 355), PortionOption('500ml 병', 500),
  ],
  'tea|차|녹차|홍차|밀크티': [
    PortionOption('1잔 (240ml)', 240), PortionOption('1병 (350ml)', 350),
    PortionOption('대용량 (500ml)', 500),
  ],
  'milk|우유': [
    PortionOption('반컵 (100ml)', 100), PortionOption('1컵 (200ml)', 200),
    PortionOption('1팩 (200ml)', 200),
  ],
  '소주|soju': [
    PortionOption('1잔 (50ml)', 50), PortionOption('2잔 (100ml)', 100),
    PortionOption('반 병 (180ml)', 180), PortionOption('1병 (360ml)', 360),
  ],
  '맥주|beer|lager': [
    PortionOption('반 캔 (250ml)', 250), PortionOption('1캔 (500ml)', 500),
    PortionOption('생맥 1잔 (425ml)', 425), PortionOption('큰잔 (1000ml)', 1000),
  ],
  '와인|wine': [
    PortionOption('1잔 (150ml)', 150), PortionOption('2잔 (300ml)', 300),
    PortionOption('반 병 (375ml)', 375), PortionOption('1병 (750ml)', 750),
  ],
  '막걸리|makgeolli': [
    PortionOption('1잔 (200ml)', 200), PortionOption('반 병 (375ml)', 375),
    PortionOption('1병 (750ml)', 750),
  ],
  '위스키|whiskey|whisky': [
    PortionOption('1샷 (30ml)', 30), PortionOption('2샷 (60ml)', 60),
    PortionOption('온더락 (90ml)', 90),
  ],
  '하이볼|highball': [
    PortionOption('1잔 (300ml)', 300), PortionOption('큰잔 (450ml)', 450),
  ],
  '술': [
    PortionOption('1잔 (50ml)', 50), PortionOption('2잔 (100ml)', 100),
    PortionOption('1병 (360ml)', 360),
  ],
};
