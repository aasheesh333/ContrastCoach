import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/settings/health_connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Health Connect renders v4 chrome (title, big card + Connect button, Permissions 3 rows, SQLCipher footnote)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const HealthConnectScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Health Connect'), findsOneWidget);
    expect(find.text('Smarter recovery score'), findsOneWidget);
    expect(find.textContaining('Connect Health Connect'), findsAtLeast(1));
    expect(find.text('Permissions'), findsOneWidget);
    expect(find.textContaining('Heart rate variability'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.textContaining('Resting heart rate'), findsOneWidget);
    expect(find.textContaining('Processed on-device'), findsOneWidget);
  });
}
