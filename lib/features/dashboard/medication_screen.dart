import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/medication_body.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _auth = AuthService();
  final _nutritionService = NutritionService();
  UserModel? _userProfile;
  List<String> _dailySelected = [];
  List<String> _chronicSelected = [];
  bool _isSaving = false;
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
    final uid = _auth.currentUser?.id ?? '';
    if (uid.isEmpty) return;
    final profile = await _auth.getUserProfile(uid);
    final todayLog = await _nutritionService.getDailyLog(uid, _todayDate);
    if (!mounted || profile == null) return;
    setState(() {
      _userProfile = profile;
      _chronicSelected = [...profile.medications];
      _dailySelected = todayLog.dailyMedications.isNotEmpty
          ? [...todayLog.dailyMedications]
          : [...profile.medications];
    });
  }

  bool get _supportsExercise {
    final goal = _userProfile?.goal;
    return goal == HealthGoal.diet || goal == HealthGoal.muscle;
  }

  Future<void> _save() async {
    final profile = _userProfile;
    final uid = _auth.currentUser?.id ?? '';
    if (profile == null || uid.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await _auth.saveUserProfile(
        profile.copyWith(medications: _chronicSelected),
      );
    } catch (e) {
      debugPrint('❌ saveUserProfile 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상시 복용약 저장 실패: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    try {
      await _nutritionService.saveDailyMedications(
        uid,
        _todayDate,
        _dailySelected,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘 복용 약과 상시 복용약이 저장되었습니다.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    } catch (e) {
      debugPrint('❌ saveDailyMedications 실패: uid=$uid, date=$_todayDate, error=$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오늘 복용 기록 저장 실패: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _friendlyMedicationError(Object error) {
    final message = error.toString();
    if (message.contains('permission') || message.contains('row-level')) {
      return 'Supabase 권한이 없습니다. RLS 정책과 로그인 상태를 확인해주세요.';
    }
    if (message.contains('unavailable') || message.contains('network')) {
      return '네트워크 연결을 확인해주세요.';
    }
    return message;
  }

  void _onDailyToggled(String med, bool selected) {
    setState(() {
      if (selected) {
        _dailySelected = [..._dailySelected, med];
      } else {
        _dailySelected = _dailySelected.where((m) => m != med).toList();
      }
    });
  }

  void _onChronicToggled(String med, bool selected) {
    setState(() {
      if (selected) {
        _chronicSelected = [..._chronicSelected, med];
      } else {
        _chronicSelected = _chronicSelected.where((m) => m != med).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.id ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('복용 약 관리'),
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
        currentRoute: '/medications',
        showExercise: _supportsExercise,
      ),
      body: uid.isEmpty
          ? const Center(child: Text('로그인이 필요합니다'))
          : _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : MedicationBody(
              userProfile: _userProfile!,
              dailySelected: _dailySelected,
              chronicSelected: _chronicSelected,
              isSaving: _isSaving,
              onDailyToggled: _onDailyToggled,
              onChronicToggled: _onChronicToggled,
              onSave: _save,
            ),
    );
  }
}
