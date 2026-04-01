import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/features/auth/screens/splash_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/login_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/signup_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/profile_setup_screen.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final authService = AuthService();
    final authState = authService.authStateChanges;

    final isAuthenticated = await authState.first;

    final isSplash = state.matchedLocation == '/splash';
    final isLogin = state.matchedLocation == '/login';
    final isSignup = state.matchedLocation == '/signup';
    final isProfileSetup = state.matchedLocation == '/profile-setup';

    if (isAuthenticated != null) {
      if (isSplash || isLogin || isSignup || isProfileSetup) {
        return '/home';
      }
      return null;
    }

    if (isSplash) {
      return null;
    }

    if (isLogin || isSignup) {
      return null;
    }

    return '/login';
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
