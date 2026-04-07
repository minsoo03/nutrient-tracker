import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:nutrient_tracker/services/medicine_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _auth = AuthService();
  UserModel? _userProfile;
  List<String> _selected = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final profile = await _auth.getUserProfile(uid);
    if (!mounted || profile == null) return;
    setState(() {
      _userProfile = profile;
      _selected = [...profile.medications];
    });
  }

  bool get _supportsExercise {
    final goal = _userProfile?.goal;
    return goal == HealthGoal.diet || goal == HealthGoal.muscle;
  }

  Future<void> _save() async {
    final profile = _userProfile;
    if (profile == null) return;
    setState(() => _isSaving = true);
    try {
      await _auth.saveUserProfile(profile.copyWith(medications: _selected));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복용 약이 저장되었습니다.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('약 저장 실패: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';
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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '복용 중인 약 카테고리',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '선택한 약은 간/신장 무리 수치 계산에 반영됩니다.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: MedicineService.allCategories.map((medication) {
                          final isSelected = _selected.contains(medication);
                          return FilterChip(
                            label: Text(medication),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selected = [..._selected, medication];
                                } else {
                                  _selected = _selected
                                      .where((item) => item != medication)
                                      .toList();
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('저장'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
