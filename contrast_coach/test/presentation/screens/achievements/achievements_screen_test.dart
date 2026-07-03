import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/achievements/achievements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Achievements renders header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const AchievementsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Achievements'), findsOneWidget);
  });
}
