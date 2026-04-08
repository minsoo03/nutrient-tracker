import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';

class AddEntryHubScreen extends StatelessWidget {
  const AddEntryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록 추가'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _HubCard(
              icon: Icons.restaurant_menu,
              title: '음식',
              subtitle: '식사와 간식 기록',
              onTap: () => context.push('/add-food?mode=food'),
            ),
            _HubCard(
              icon: Icons.local_drink_outlined,
              title: '음료/보충제',
              subtitle: '음료, 프로틴, 술',
              onTap: () => context.push('/add-food?mode=drink'),
            ),
            _HubCard(
              icon: Icons.medication_outlined,
              title: '약',
              subtitle: '오늘 복용 약 기록',
              onTap: () => context.push('/medications'),
            ),
            _HubCard(
              icon: Icons.fitness_center,
              title: '운동',
              subtitle: '운동 소모 기록',
              onTap: () => context.push('/exercise'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
