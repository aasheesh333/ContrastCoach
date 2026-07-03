import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/breathwork/breathwork_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Breathwork renders v4 chrome (BOX BREATHING, INHALE, exit, round)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const BreathworkScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('BOX BREATHING'), findsOneWidget);
    expect(find.text('INHALE'), findsOneWidget);
    expect(find.textContaining('Round'), findsOneWidget);
    expect(find.textContaining('tap anywhere to pause'), findsOneWidget);
    expect(find.text('✕'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
