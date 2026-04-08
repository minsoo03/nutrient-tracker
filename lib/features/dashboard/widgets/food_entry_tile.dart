import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';

/// 식단 기록 항목 하나를 표시하는 타일 (스와이프 삭제 지원)
class FoodEntryTile extends StatelessWidget {
  final FoodEntryModel entry;
  final Future<void> Function() onDelete;

  const FoodEntryTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _sanitizeFoodName(entry.foodName);

    return Dismissible(
      key: Key(entry.id ?? entry.foodName),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) async => onDelete(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          displayName,
          style: const TextStyle(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '탄 ${entry.carbsG.toStringAsFixed(1)}g · 단 ${entry.proteinG.toStringAsFixed(1)}g · 지 ${entry.fatG.toStringAsFixed(1)}g',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(entry.displayAmountText,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: '삭제',
              onPressed: () async {
                final confirmed = await _confirmDelete(context);
                if (confirmed == true) {
                  await onDelete();
                }
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('기록 삭제'),
        content: Text('"${_sanitizeFoodName(entry.foodName)}" 기록을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  static String _sanitizeFoodName(String raw) {
    return raw
        .replaceAll(' · null', '')
        .replaceAll('· null', '')
        .replaceAll('null', '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}
