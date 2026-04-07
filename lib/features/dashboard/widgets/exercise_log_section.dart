import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/models/exercise_entry_model.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

class ExerciseLogSection extends StatelessWidget {
  final String uid;
  final String date;
  final NutritionService nutritionService;

  const ExerciseLogSection({
    super.key,
    required this.uid,
    required this.date,
    required this.nutritionService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExerciseEntryModel>>(
      stream: nutritionService.watchExerciseEntries(uid, date),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '운동 기록을 불러오지 못했습니다: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
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
                    Icon(Icons.fitness_center,
                        size: 36, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text(
                      '아직 기록된 운동이 없어요',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final totalBurned =
            entries.fold<double>(0, (sum, entry) => sum + entry.burnedCalories);

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '운동 기록',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${totalBurned.toStringAsFixed(0)} kcal 소모',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...entries.map((entry) => _ExerciseTile(
                    entry: entry,
                    onDelete: () async {
                      if (entry.id != null) {
                        await nutritionService.deleteExerciseEntry(
                          uid,
                          date,
                          entry.id!,
                        );
                      }
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseEntryModel entry;
  final Future<void> Function() onDelete;

  const _ExerciseTile({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.local_fire_department_outlined,
          color: AppColors.warning),
      title: Text(entry.exerciseName, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        '${entry.durationMinutes.toStringAsFixed(0)}분',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${entry.burnedCalories.toStringAsFixed(0)} kcal',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: '삭제',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('운동 기록 삭제'),
                  content: Text('"${entry.exerciseName}" 기록을 삭제할까요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await onDelete();
              }
            },
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
