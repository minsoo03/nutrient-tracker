import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:nutrient_tracker/features/auth/widgets/profile_form_widgets.dart';

void main() {
  testWidgets('GoalSelector renders options and reacts to taps', (
    WidgetTester tester,
  ) async {
    HealthGoal selected = HealthGoal.health;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalSelector(
            selected: selected,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('근육 증가'), findsOneWidget);
    expect(find.text('다이어트'), findsOneWidget);
    expect(find.text('건강 관리'), findsOneWidget);
    expect(find.text('의료 목적'), findsOneWidget);

    await tester.tap(find.text('의료 목적'));
    await tester.pump();

    expect(selected, HealthGoal.medical);
  });
}
