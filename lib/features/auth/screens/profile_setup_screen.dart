import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/auth/widgets/profile_form_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  Gender _selectedGender = Gender.male;
  HealthGoal _selectedGoal = HealthGoal.health;
  bool _hasKidneyDisease = false;
  bool _hasLiverDisease = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final user = authService._auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final userModel = UserModel(
        uid: user.uid,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        goal: _selectedGoal,
        dailyCalorieTarget: 2000,
        dailyProteinTarget: 150,
        hasKidneyDisease: _hasKidneyDisease,
        hasLiverDisease: _hasLiverDisease,
        medications: [],
        createdAt: DateTime.now(),
      );

      await authService.saveUserProfile(userModel);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: '나이'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            GenderDropdown(
              selectedGender: _selectedGender,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGender = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: '신장 (cm)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: '몸무게 (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            HealthGoalDropdown(
              selectedGoal: _selectedGoal,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGoal = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            DiseaseToggleRow(
              label: '신장 질환 여부',
              value: _hasKidneyDisease,
              onChanged: (value) {
                setState(() {
                  _hasKidneyDisease = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DiseaseToggleRow(
              label: '간 질환 여부',
              value: _hasLiverDisease,
              onChanged: (value) {
                setState(() {
                  _hasLiverDisease = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSaveProfile,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
