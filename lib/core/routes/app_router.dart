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
