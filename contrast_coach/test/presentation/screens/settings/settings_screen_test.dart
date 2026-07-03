import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders v4 profile hub "You" title and rowlinks', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const SettingsScreen(),
      ),
    );
    // Wait for async DB/Firestore load + AnimatedSwitcher (260ms)
    await tester.pump(const Duration(milliseconds: 500));

    // v4 .name "You" 28/w800/ls-.7 (not "Profile" AppBar title)
    expect(find.text('You'), findsOneWidget);

    // Avatar emoji present (default 🧑)
    expect(find.text('🧑'), findsWidgets);

    // Edit profile ghost2 button
    expect(find.text('Edit profile'), findsOneWidget);

    // Stats trio labels
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Longest'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);

    // 11 rowlink labels present
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('History & calendar'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Challenges'), findsOneWidget);
    expect(find.text('Account & security'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Health Connect'), findsOneWidget);
    expect(find.text('Home-screen widgets'), findsOneWidget);
    expect(find.text('Subscription'), findsOneWidget);
    expect(find.text('Data & backup'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget);

    // Subscription subtext "Free plan"
    expect(find.text('Free plan'), findsOneWidget);

    // Scroll down to reveal the Go Pro CTA (below the fold in 800x600 viewport)
    await tester.scrollUntilVisible(
      find.textContaining('Go Pro'),
      200,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Go Pro'), findsOneWidget);
  });
}
