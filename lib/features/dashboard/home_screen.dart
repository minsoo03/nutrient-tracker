import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/food_log_section.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/manual_food_entry_dialog.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/nutrition_widgets.dart';

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

  NutritionTargets get _targets {
    final p = _userProfile;
    if (p == null) return NutritionTargets.defaultTargets;
    return NutritionTargets(
      calories: p.dailyCalorieTarget,
      proteinG: NutritionCalculator.recommendedProteinTarget(
        weightKg: p.weightKg,
        goal: p.goal,
        hasKidneyDisease: p.hasKidneyDisease,
        hasLiverDisease: p.hasLiverDisease,
      ),
      carbsG: p.dailyCarbsTarget,
      fatG: p.dailyFatTarget,
      sodiumMg: p.dailySodiumTarget,
      caffeineMax: p.goal == HealthGoal.medical ? 200 : 400,
      sugarMax: 100,
      fiberMin: p.gender == Gender.male ? 38 : 25,
    );
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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: uid.isEmpty
          ? const Center(child: Text('로그인이 필요합니다'))
          : StreamBuilder<DailyLogModel>(
              stream: _nutritionService.watchDailyLog(uid, _todayDate),
              builder: (context, snapshot) {
                final log = snapshot.data ?? DailyLogModel.empty(_todayDate);
                return _HomeContent(
                  log: log,
                  targets: _targets,
                  userProfile: _userProfile,
                  uid: uid,
                  date: _todayDate,
                  nutritionService: _nutritionService,
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
            onPressed: () => context.push('/add-food'),
            icon: const Icon(Icons.add),
            label: const Text('음식 추가'),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final DailyLogModel log;
  final NutritionTargets targets;
  final UserModel? userProfile;
  final String uid;
  final String date;
  final NutritionService nutritionService;

  const _HomeContent({
    required this.log,
    required this.targets,
    required this.userProfile,
    required this.uid,
    required this.date,
    required this.nutritionService,
  });

  @override
  Widget build(BuildContext context) {
    final liverLoad = NutritionCalculator.estimateLiverLoad(
      log: log,
      targets: targets,
      medications: userProfile?.medications ?? const [],
      hasLiverDisease: userProfile?.hasLiverDisease ?? false,
      hasKidneyDisease: userProfile?.hasKidneyDisease ?? false,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 날짜
          Text(_dateLabel(), textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),

          // 칼로리
          CaloriesCard(log: log, target: targets.calories),
          const SizedBox(height: 10),

          // 탄단지
          const _Label('주요 영양소'),
          MacrosRow(log: log, carbsTarget: targets.carbsG,
              proteinTarget: targets.proteinG, fatTarget: targets.fatG),
          const SizedBox(height: 10),

          // 건강 지표
          const _Label('건강 지표'),
          NutrientRow(log: log, caffeineMax: targets.caffeineMax,
              sodiumMax: targets.sodiumMg, sugarMax: targets.sugarMax,
              fiberMin: targets.fiberMin, liverLoad: liverLoad),
          const SizedBox(height: 16),

          // 오늘의 식단 로그
          const _Label('오늘의 식단'),
          FoodLogSection(uid: uid, date: date, nutritionService: nutritionService),
        ],
      ),
    );
  }

  String _dateLabel() {
    final now = DateTime.now();
    const w = ['월', '화', '수', '목', '금', '토', '일'];
    return '${now.month}월 ${now.day}일 (${w[now.weekday - 1]})';
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
    );
  }
}
