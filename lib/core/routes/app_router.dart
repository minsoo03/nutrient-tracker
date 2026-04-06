import 'package:go_router/go_router.dart';
import 'package:nutrient_tracker/features/auth/screens/splash_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/login_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/signup_screen.dart';
import 'package:nutrient_tracker/features/auth/screens/profile_setup_screen.dart';
import 'package:nutrient_tracker/features/dashboard/home_screen.dart';
import 'package:nutrient_tracker/features/dashboard/add_food_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
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
    GoRoute(
      path: '/add-food',
      builder: (context, state) => const AddFoodScreen(),
    ),
  ],
);
