import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Paywall renders v4 sheet content (badge, headline, trust, features, reviews, links)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const PaywallScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('CONTRASTCOACH PRO'), findsOneWidget);
    expect(find.text('See what actually works for you'), findsOneWidget);
    expect(find.textContaining('50k+'), findsOneWidget);
    expect(find.textContaining('4.9'), findsOneWidget);
    expect(find.textContaining('92%'), findsOneWidget);
    expect(find.text('All protocols'), findsOneWidget);
    expect(find.text('Breathwork'), findsOneWidget);
    expect(find.textContaining('Finally a recovery app'), findsOneWidget);
    expect(find.textContaining('HRV score keeps me honest'), findsOneWidget);
    expect(find.textContaining('Restore'), findsOneWidget);
    expect(find.textContaining('Terms'), findsAtLeast(1));
    expect(find.textContaining('Privacy'), findsAtLeast(1));
    expect(find.textContaining('Maybe later'), findsOneWidget);
  });
}
