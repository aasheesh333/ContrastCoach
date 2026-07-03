import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/challenges/challenges_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Challenges renders header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const ChallengesScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Challenges'), findsOneWidget);
  });
}
