import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';
import 'package:nutrient_tracker/utils/portion_helper.dart';

class FoodLogSection extends StatelessWidget {
  final String uid;
  final String date;
  final NutritionService nutritionService;

  const FoodLogSection({
    super.key,
    required this.uid,
    required this.date,
    required this.nutritionService,
  });

  static const _mealOrder = ['breakfast', 'lunch', 'dinner', 'snack'];
  static const _mealLabels = {
    'breakfast': '🌅 아침',
    'lunch': '☀️ 점심',
    'dinner': '🌙 저녁',
    'snack': '🍎 간식',
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodEntryModel>>(
      stream: nutritionService.watchEntries(uid, date),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(height: 8),
                  const Text(
                    '식단 기록을 불러오지 못했습니다',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        final entries = snapshot.data ?? [];

        if (entries.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 36, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text('아직 기록된 음식이 없어요',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('+ 버튼을 눌러 음식을 추가해보세요',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }

        // 식사 타입별 그룹핑
        final grouped = <String, List<FoodEntryModel>>{};
        for (final e in entries) {
          grouped.putIfAbsent(e.mealType, () => []).add(e);
        }

        return Column(
          children: _mealOrder
              .where((type) => grouped.containsKey(type))
              .map((type) => _MealGroup(
                    label: _mealLabels[type] ?? type,
                    entries: grouped[type]!,
                    onDelete: (id) => nutritionService.deleteFoodEntry(uid, date, id),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MealGroup extends StatelessWidget {
  final String label;
  final List<FoodEntryModel> entries;
  final Future<void> Function(String id) onDelete;

  const _MealGroup({
    required this.label,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalCal = entries.fold<double>(0, (s, e) => s + e.calories);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${totalCal.toStringAsFixed(0)} kcal',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...entries.map((entry) => _EntryTile(
                entry: entry,
                onDelete: () async {
                  if (entry.id != null) await onDelete(entry.id!);
                },
              )),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final FoodEntryModel entry;
  final Future<void> Function() onDelete;

  const _EntryTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final displayName = _sanitizeFoodName(entry.foodName);
    final amountUnit = PortionHelper.usesMilliliters(entry.foodName) ? 'ml' : 'g';

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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${entry.calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${entry.amountG.toStringAsFixed(0)}$amountUnit',
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

  String _sanitizeFoodName(String raw) {
    return raw
        .replaceAll(' · null', '')
        .replaceAll('· null', '')
        .replaceAll('null', '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}
