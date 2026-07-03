import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/help/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Help screen renders v4 chrome (title, 4 FAQ rowlinks, Contact support, version footnote)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const HelpScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Help & support'), findsOneWidget);
    expect(find.text('How cold should the plunge be?'), findsOneWidget);
    expect(find.text('How long in the sauna?'), findsOneWidget);
    expect(find.text('How is my Recovery Score calculated?'), findsOneWidget);
    expect(find.text('Manage or cancel subscription'), findsOneWidget);
    expect(find.text('Contact support'), findsOneWidget);
    expect(find.textContaining('ContrastCoach v4.0'), findsOneWidget);
  });
}
