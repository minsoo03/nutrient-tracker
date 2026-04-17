import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/medication_body.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/medication_dose_sheet.dart';
import 'package:nutrient_tracker/models/daily_medication_entry_model.dart';
import 'package:nutrient_tracker/services/medicine_service.dart';
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
  // 오늘 복용: 약이름 → 수량 (수량 1이면 그냥 이름만 저장)
  Map<String, int> _dailyDoses = {};
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
      if (todayLog.dailyMedicationEntries.isNotEmpty) {
        _dailyDoses = {
          for (final entry in todayLog.dailyMedicationEntries)
            entry.name: entry.count,
        };
      } else {
        final source = todayLog.dailyMedications.isNotEmpty
            ? todayLog.dailyMedications
            : profile.medications;
        _dailyDoses = MedicineService.decodeDoses(source);
      }
    });
  }

  bool get _supportsExercise {
    final goal = _userProfile?.goal;
    return goal == HealthGoal.diet || goal == HealthGoal.muscle;
  }

  /// 단기 복용약 칩 탭 — 이미 선택됐으면 해제, 아니면 수량 선택 시트 열기
  Future<void> _onAcuteChipTapped(String med, bool isCurrentlySelected) async {
    if (isCurrentlySelected) {
      setState(() => _dailyDoses.remove(med));
      return;
    }
    final dose = await MedicationDoseSheet.show(
      context,
      medicationName: med,
      initialDose: _dailyDoses[med] ?? 1,
    );
    if (!mounted || dose == null) return;
    setState(() => _dailyDoses[med] = dose);
  }

  /// 전체 목록 칩 toggle — 수량 없이 단순 on/off
  void _onAllToggled(String med, bool selected) {
    setState(() {
      if (selected) {
        _dailyDoses[med] = _dailyDoses[med] ?? 1;
      } else {
        _dailyDoses.remove(med);
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('상시 복용약 저장 실패: ${_friendlyError(e)}'),
        backgroundColor: AppColors.error,
      ));
      setState(() => _isSaving = false);
      return;
    }
    try {
      final entries = _dailyDoses.entries
          .map(
            (e) => DailyMedicationEntryModel(
              name: e.key,
              count: e.value,
              isCustom: !MedicineService.allCategories.contains(e.key) &&
                  !MedicineService.acuteCategories.contains(e.key),
            ),
          )
          .toList(growable: false);
      await _nutritionService.saveDailyMedications(uid, _todayDate, entries);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('오늘 복용 약과 상시 복용약이 저장되었습니다.'),
        backgroundColor: AppColors.primary,
      ));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('오늘 복용 기록 저장 실패: ${_friendlyError(e)}'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('permission') || msg.contains('row-level')) {
      return 'Supabase 권한이 없습니다.';
    }
    if (msg.contains('unavailable') || msg.contains('network')) {
      return '네트워크 연결을 확인해주세요.';
    }
    return msg;
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
              dailyDoses: _dailyDoses,
              chronicSelected: _chronicSelected,
              isSaving: _isSaving,
              onAcuteChipTapped: _onAcuteChipTapped,
              onAllToggled: _onAllToggled,
              onChronicToggled: _onChronicToggled,
              onSave: _save,
            ),
    );
  }
}
