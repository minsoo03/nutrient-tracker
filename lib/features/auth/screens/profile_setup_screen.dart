import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/auth/widgets/profile_setup_steps.dart';
import 'package:nutrient_tracker/services/nutrition_calculator.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

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

  void _nextPage() {
    _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _step++);
  }

  void _prevPage() {
    _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _step--);
  }

  Future<void> _handleSave() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _ageCtrl.text.trim().isEmpty ||
        _heightCtrl.text.trim().isEmpty ||
        _weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이름, 나이, 키, 몸무게를 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      final user = auth.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다');

      final targets = NutritionCalculator.calculate(
        age: int.parse(_ageCtrl.text),
        gender: _gender,
        heightCm: double.parse(_heightCtrl.text),
        weightKg: double.parse(_weightCtrl.text),
        goal: _goal,
        hasKidneyDisease: _hasKidney,
        hasLiverDisease: _hasLiver,
      );

      await auth.saveUserProfile(UserModel(
        uid: user.uid,
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        gender: _gender,
        heightCm: double.parse(_heightCtrl.text),
        weightKg: double.parse(_weightCtrl.text),
        goal: _goal,
        dailyCalorieTarget: targets.calories,
        dailyProteinTarget: targets.proteinG,
        dailyCarbsTarget: targets.carbsG,
        dailyFatTarget: targets.fatG,
        dailySodiumTarget: targets.sodiumMg,
        hasKidneyDisease: _hasKidney,
        hasLiverDisease: _hasLiver,
        medications: [],
        createdAt: DateTime.now(),
      ));

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
                icon: const Icon(Icons.arrow_back), onPressed: _prevPage)
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
            nameCtrl: _nameCtrl, ageCtrl: _ageCtrl, gender: _gender,
            onGenderChanged: (g) => setState(() => _gender = g),
            onNext: _nextPage,
          ),
          ProfileStep2(
            heightCtrl: _heightCtrl, weightCtrl: _weightCtrl, goal: _goal,
            onGoalChanged: (g) => setState(() => _goal = g),
            onNext: _nextPage,
          ),
          ProfileStep3(
            hasKidney: _hasKidney, hasLiver: _hasLiver,
            onKidneyChanged: (v) => setState(() => _hasKidney = v),
            onLiverChanged: (v) => setState(() => _hasLiver = v),
            onSave: _handleSave, isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
