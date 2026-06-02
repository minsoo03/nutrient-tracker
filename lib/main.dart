import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutrient_tracker/core/theme/app_theme.dart';
import 'package:nutrient_tracker/core/routes/app_router.dart';
import 'package:nutrient_tracker/services/exercise_catalog_service.dart';
import 'package:nutrient_tracker/services/medication_catalog_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // LLM 시드 카탈로그를 병렬로 미리 로드 (실패해도 앱은 fallback 데이터로 동작)
  await Future.wait([
    MedicationCatalogService.loadAll(),
    ExerciseCatalogService.loadAll(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nutrient Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

class MissingSupabaseConfigApp extends StatelessWidget {
  const MissingSupabaseConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Supabase 설정이 필요합니다',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  '.env에 SUPABASE_URL과 SUPABASE_ANON_KEY를 입력하고, '
                  'Supabase SQL editor에서 supabase/schema.sql을 실행해주세요.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
