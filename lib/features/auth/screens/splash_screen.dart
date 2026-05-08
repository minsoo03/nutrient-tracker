import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    if (mounted) {
      setState(() => _errorMessage = null);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final auth = AuthService();
    final user = await auth.authStateChanges.first;
    if (!mounted) return;

    if (user == null) {
      context.go('/login');
      return;
    }

    // 프로필 존재 여부 확인 → 없으면 /profile-setup으로
    // 네트워크 오류 등으로 실패 시 home으로 가지 않고 에러 표시 후 재시도 옵션 제공
    try {
      final profile = await auth.getUserProfile(user.id);
      if (!mounted) return;
      if (profile == null) {
        context.go('/profile-setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '프로필을 불러오지 못했습니다. 네트워크를 확인하고 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monitor_heart, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              'Nutrient Tracker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            if (_errorMessage == null)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _navigate,
                child: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
