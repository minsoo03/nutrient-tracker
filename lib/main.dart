import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/theme/app_theme.dart';
import 'package:nutrient_tracker/core/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nutrient Tracker',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
