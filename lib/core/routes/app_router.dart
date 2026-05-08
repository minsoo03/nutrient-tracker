import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/features/auth/screens/splash_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/login_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/signup_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/profile_setup_screen.dart';
import 'package:nutrient_tracker/features/dashboard/add_entry_hub_screen.dart';
import 'package:nutrient_tracker/features/dashboard/home_screen.dart';
import 'package:nutrient_tracker/features/dashboard/add_food_screen.dart';
import 'package:nutrient_tracker/features/dashboard/exercise_screen.dart';
import 'package:nutrient_tracker/features/dashboard/history_screen.dart';
import 'package:nutrient_tracker/features/dashboard/medication_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 인증 상태 변경을 GoRouter에 알리기 위한 어댑터
class _SupabaseAuthRefresh extends ChangeNotifier {
  _SupabaseAuthRefresh() {
    _sub = Supabase.instance.client.auth.onAuthStateChange
        .listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authRefresh = _SupabaseAuthRefresh();

/// 비로그인 사용자도 들어올 수 있는 경로 — 그 외는 모두 세션 필요
const _publicPaths = <String>{'/splash', '/login', '/signup', '/profile-setup'};

String? _authGuard(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  final loggedIn = session != null;
  final path = state.matchedLocation;

  // 비로그인 사용자가 보호 경로 진입 시도 → /login 강제
  if (!loggedIn && !_publicPaths.contains(path)) {
    return '/login';
  }

  // 이미 로그인된 사용자가 로그인/회원가입 페이지로 가면 → /home
  if (loggedIn && (path == '/login' || path == '/signup')) {
    return '/home';
  }

  return null; // 현재 경로 유지
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _authRefresh,
  redirect: _authGuard,
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
      builder: (context, state) => ProfileSetupScreen(
        userId: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-entry',
      builder: (context, state) => const AddEntryHubScreen(),
    ),
    GoRoute(
      path: '/add-food',
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'] == 'drink'
            ? AddFoodMode.drink
            : AddFoodMode.food;
        return AddFoodScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/exercise',
      builder: (context, state) => const ExerciseScreen(),
    ),
    GoRoute(
      path: '/medications',
      builder: (context, state) => const MedicationScreen(),
    ),
  ],
);
