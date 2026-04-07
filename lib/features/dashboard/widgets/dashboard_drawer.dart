import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';

class DashboardDrawer extends StatelessWidget {
  final UserModel? userProfile;
  final String currentRoute;
  final bool showExercise;

  const DashboardDrawer({
    super.key,
    required this.userProfile,
    required this.currentRoute,
    this.showExercise = false,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              accountName: Text(userProfile?.name ?? '사용자'),
              accountEmail: Text(
                userProfile == null ? '영양 기록 관리' : '식단과 건강 지표 확인',
              ),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (userProfile?.name.isNotEmpty ?? false)
                      ? userProfile!.name.characters.first
                      : 'N',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today_outlined),
              title: const Text('오늘 기록'),
              selected: currentRoute == '/home',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/home') {
                  context.go('/home');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('기록 캘린더'),
              selected: currentRoute == '/history',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/history') {
                  context.go('/history');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication_outlined),
              title: const Text('복용 약 관리'),
              selected: currentRoute == '/medications',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/medications') {
                  context.go('/medications');
                }
              },
            ),
            if (showExercise)
              ListTile(
                leading: const Icon(Icons.fitness_center_outlined),
                title: const Text('운동 기록'),
                selected: currentRoute == '/exercise',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/exercise') {
                    context.go('/exercise');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
