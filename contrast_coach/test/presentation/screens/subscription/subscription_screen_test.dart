import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/subscription/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Subscription screen renders v4 chrome (title, Current plan, 3 plans, Start free trial, Restore)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const SubscriptionScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Subscription'), findsOneWidget);
    expect(find.textContaining('Current plan · Free'), findsOneWidget);
    expect(find.textContaining('3 protocols · basic score · local only'),
        findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Lifetime'), findsOneWidget);
    expect(find.textContaining('SAVE 50%'), findsOneWidget);
    expect(find.text(r'$29.99'), findsOneWidget);
    expect(find.text(r'$4.99'), findsOneWidget);
    expect(find.text(r'$79.99'), findsOneWidget);
    expect(find.text('Start free trial'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
  });
}
