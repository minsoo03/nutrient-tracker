import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_daily_view.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:nutrient_tracker/models/daily_log_model.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _auth = AuthService();
  final _nutritionService = NutritionService();
  UserModel? _userProfile;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final profile = await _auth.getUserProfile(uid);
    if (mounted) {
      setState(() => _userProfile = profile);
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
    final selectedDateKey = _dateKey(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 캘린더'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '오늘로 이동',
            onPressed: () => setState(() => _selectedDate = DateTime.now()),
            icon: const Icon(Icons.today),
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
        currentRoute: '/history',
        showExercise: _supportsExercise,
      ),
      body: uid.isEmpty
          ? const Center(child: Text('로그인이 필요합니다'))
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.month}월 ${_selectedDate.day}일 기록',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CalendarDatePicker(
                          initialDate: _selectedDate,
                          firstDate: DateTime(2024, 1, 1),
                          lastDate: DateTime.now(),
                          onDateChanged: (date) {
                            setState(() => _selectedDate = date);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<DailyLogModel>(
                    stream: _nutritionService.watchDailyLog(uid, selectedDateKey),
                    builder: (context, snapshot) {
                      final log = snapshot.data ?? DailyLogModel.empty(selectedDateKey);
                      return DashboardDailyView(
                        log: log,
                        targets: _targets,
                        userProfile: _userProfile,
                        uid: uid,
                        date: selectedDateKey,
                        dateLabel: _dateLabel(_selectedDate),
                        nutritionService: _nutritionService,
                        showExercise: _supportsExercise,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _dateLabel(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
  }
}
