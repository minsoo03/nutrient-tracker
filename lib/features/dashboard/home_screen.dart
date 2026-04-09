import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_daily_view.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/manual_food_entry_dialog.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/weight_update_dialog.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _nutritionService = NutritionService();
  late String _todayDate;
  UserModel? _userProfile;

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

  bool get _shouldPromptWeightUpdate {
    final profile = _userProfile;
    if (profile == null) return false;
    return DateTime.now().difference(profile.lastWeightUpdatedAt).inDays >= 7;
  }

  Future<void> _showWeightUpdateDialog() async {
    final profile = _userProfile;
    if (profile == null) return;
    final updated = await showWeightUpdateDialog(
      context: context,
      profile: profile,
      authService: _auth,
    );
    if (updated != null && mounted) {
      setState(() => _userProfile = updated);
    }
  }

  NutritionTargets get _targets {
    final p = _userProfile;
    if (p == null) return NutritionTargets.defaultTargets;
    return NutritionCalculator.fromUserProfile(p);
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
        title: Text(
          _userProfile != null ? '안녕하세요, ${_userProfile!.name}님 👋' : '오늘의 영양소',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '기록 캘린더',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
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
        currentRoute: '/home',
        showExercise: _supportsExercise,
      ),
      body: uid.isEmpty
          ? const Center(child: Text('로그인이 필요합니다'))
          : StreamBuilder<DailyLogModel>(
              stream: _nutritionService.watchDailyLog(uid, _todayDate),
              builder: (context, snapshot) {
                final log = snapshot.data ?? DailyLogModel.empty(_todayDate);
                return DashboardDailyView(
                  log: log,
                  targets: _targets,
                  userProfile: _userProfile,
                  uid: uid,
                  date: _todayDate,
                  dateLabel: _dateLabel(DateTime.now()),
                  nutritionService: _nutritionService,
                  showExercise: _supportsExercise,
                  showWeightUpdatePrompt: _shouldPromptWeightUpdate,
                  currentWeightKg: _userProfile?.weightKg,
                  lastWeightUpdatedAt: _userProfile?.lastWeightUpdatedAt,
                  onUpdateWeight: _showWeightUpdateDialog,
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manual-entry-fab',
            onPressed: uid.isEmpty
                ? null
                : () => showManualFoodEntryDialog(
                      context: context,
                      uid: uid,
                      date: _todayDate,
                      nutritionService: _nutritionService,
                    ),
            backgroundColor: AppColors.secondary,
            icon: const Icon(Icons.edit_note),
            label: const Text('직접 입력'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'search-food-fab',
            onPressed: () => context.push('/add-entry'),
            icon: const Icon(Icons.add),
            label: const Text('기록 추가'),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
  }
}
