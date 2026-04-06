import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    if (email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
      setState(() {
        _errorMessage = '이메일과 비밀번호를 모두 입력해주세요';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _errorMessage = '올바른 이메일 형식으로 입력해주세요';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = '비밀번호는 6자 이상이어야 합니다';
      });
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.signUpWithEmail(email, password);

      if (mounted) {
        context.go('/profile-setup');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
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
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Nutrient Tracker',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: 'example@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordConfirmController,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
              ),
              obscureText: true,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
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
                  : const Text('회원가입'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('이미 계정이 있으신가요? '),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('로그인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
