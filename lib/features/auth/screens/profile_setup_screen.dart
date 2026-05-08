import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/auth/utils/profile_input_validator.dart';
import 'package:nutrient_tracker/features/auth/widgets/profile_setup_steps.dart';
import 'package:nutrient_tracker/services/medicine_service.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';

class ProfileSetupScreen extends StatefulWidget {
  /// signup 직후 세션이 없을 때를 대비해 userId를 직접 전달받음
  final String? userId;

  const ProfileSetupScreen({super.key, this.userId});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  int _step = 0;
  Gender _gender = Gender.male;
  HealthGoal _goal = HealthGoal.health;
  bool _hasKidney = false;
  bool _hasLiver = false;
  List<String> _medications = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _go(bool forward) {
    const dur = Duration(milliseconds: 300);
    forward
        ? _pageCtrl.nextPage(duration: dur, curve: Curves.easeInOut)
        : _pageCtrl.previousPage(duration: dur, curve: Curves.easeInOut);
    setState(() => _step += forward ? 1 : -1);
  }

  void _toggleMedication(String medication, bool selected) {
    setState(() {
      _medications = selected
          ? [..._medications, medication]
          : _medications.where((item) => item != medication).toList();
    });
  }

  Future<void> _handleSave() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _ageCtrl.text.trim().isEmpty ||
        _heightCtrl.text.trim().isEmpty ||
        _weightCtrl.text.trim().isEmpty) {
      _showError('이름, 나이, 키, 몸무게를 모두 입력해주세요.');
      return;
    }

    // 숫자 입력 검증 — 잘못된 값이면 FormatException으로 빠지지 않고 친절히 안내
    final ProfileInputs inputs;
    try {
      inputs = ProfileInputValidator.parse(
        ageText: _ageCtrl.text,
        heightText: _heightCtrl.text,
        weightText: _weightCtrl.text,
      );
    } on ProfileInputError catch (e) {
      _showError(e.message);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      // signup 직후 이메일 미인증 상태에서는 currentUser가 null일 수 있으므로
      // 라우트로 전달받은 userId를 우선 사용
      final uid = widget.userId ?? auth.currentUser?.id;
      if (uid == null || uid.isEmpty) throw Exception('로그인이 필요합니다');

      final targets = NutritionCalculator.calculate(
        age: inputs.age,
        gender: _gender,
        heightCm: inputs.heightCm,
        weightKg: inputs.weightKg,
        goal: _goal,
        hasKidneyDisease: _hasKidney,
        hasLiverDisease: _hasLiver,
      );

      await auth.saveUserProfile(
        UserModel(
          uid: uid,
          name: _nameCtrl.text.trim(),
          age: inputs.age,
          gender: _gender,
          heightCm: inputs.heightCm,
          weightKg: inputs.weightKg,
          goal: _goal,
          dailyCalorieTarget: targets.calories,
          dailyProteinTarget: targets.proteinG,
          dailyCarbsTarget: targets.carbsG,
          dailyFatTarget: targets.fatG,
          dailySodiumTarget: targets.sodiumMg,
          hasKidneyDisease: _hasKidney,
          hasLiverDisease: _hasLiver,
          medications: _medications,
          lastWeightUpdatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _go(false),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: Colors.grey[200],
            color: AppColors.primary,
          ),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ProfileStep1(
            nameCtrl: _nameCtrl,
            ageCtrl: _ageCtrl,
            gender: _gender,
            onGenderChanged: (g) => setState(() => _gender = g),
            onNext: () => _go(true),
          ),
          ProfileStep2(
            heightCtrl: _heightCtrl,
            weightCtrl: _weightCtrl,
            goal: _goal,
            onGoalChanged: (g) => setState(() => _goal = g),
            onNext: () => _go(true),
          ),
          ProfileStep3(
            hasKidney: _hasKidney,
            hasLiver: _hasLiver,
            onKidneyChanged: (v) => setState(() => _hasKidney = v),
            onLiverChanged: (v) => setState(() => _hasLiver = v),
            medicationOptions: MedicineService.allCategories,
            selectedMedications: _medications,
            onMedicationToggle: _toggleMedication,
            onSave: _handleSave,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
