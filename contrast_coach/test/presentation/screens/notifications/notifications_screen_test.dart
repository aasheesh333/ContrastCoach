import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Notifications screen renders v4 chrome (title, 6 .set rows, Active days chips)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const NotificationsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.textContaining('Daily reminder'), findsOneWidget);
    expect(find.textContaining('Reminder time'), findsOneWidget);
    expect(find.text('7:00 AM'), findsOneWidget);
    expect(find.textContaining('Streak at risk'), findsOneWidget);
    expect(find.textContaining('Hydration nudges'), findsOneWidget);
    expect(find.textContaining('Challenge updates'), findsOneWidget);
    expect(find.textContaining('Product news'), findsOneWidget);
    expect(find.text('Active days'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
  });
}
