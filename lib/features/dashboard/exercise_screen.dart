import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/exercise_log_section.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/manual_exercise_entry_dialog.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _auth = AuthService();
  final _nutritionService = NutritionService();
  UserModel? _userProfile;
  late String _todayDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final profile = await _auth.getUserProfile(uid);
    if (mounted) setState(() => _userProfile = profile);
  }

  bool get _supportsExercise {
    final goal = _userProfile?.goal;
    return goal == HealthGoal.diet || goal == HealthGoal.muscle;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: DashboardDrawer(
        userProfile: _userProfile,
        currentRoute: '/exercise',
        showExercise: _supportsExercise,
      ),
      body: uid.isEmpty
          ? const Center(child: Text('로그인이 필요합니다'))
          : !_supportsExercise
              ? const Center(
                  child: Text('운동 기능은 다이어트/근육 증가 목표에서 사용할 수 있습니다.'),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ExerciseLogSection(
                    uid: uid,
                    date: _todayDate,
                    nutritionService: _nutritionService,
                  ),
                ),
      floatingActionButton: uid.isEmpty || !_supportsExercise
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showManualExerciseEntryDialog(
                context: context,
                uid: uid,
                date: _todayDate,
                nutritionService: _nutritionService,
              ),
              icon: const Icon(Icons.fitness_center),
              label: const Text('운동 추가'),
            ),
    );
  }
}
