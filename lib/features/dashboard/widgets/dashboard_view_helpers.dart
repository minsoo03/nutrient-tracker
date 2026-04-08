import 'package:flutter/material.dart';

/// 대시보드 섹션 제목 레이블
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }
}

/// 체중 업데이트 유도 카드
class WeightUpdateCard extends StatelessWidget {
  final double? currentWeightKg;
  final DateTime? lastWeightUpdatedAt;
  final VoidCallback onUpdateWeight;

  const WeightUpdateCard({
    super.key,
    required this.currentWeightKg,
    required this.lastWeightUpdatedAt,
    required this.onUpdateWeight,
  });

  @override
  Widget build(BuildContext context) {
    final updatedLabel = lastWeightUpdatedAt == null
        ? '아직 체중 업데이트 기록이 없습니다.'
        : '마지막 체중 업데이트: ${lastWeightUpdatedAt!.month}/${lastWeightUpdatedAt!.day}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.monitor_weight_outlined, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentWeightKg == null
                        ? '체중을 한 번 업데이트해보세요'
                        : '현재 체중 ${currentWeightKg!.toStringAsFixed(1)}kg',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(updatedLabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            FilledButton(
              onPressed: onUpdateWeight,
              child: const Text('업데이트'),
            ),
          ],
        ),
      ),
    );
  }
}
