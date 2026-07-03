import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/settings/appearance_screen.dart';
import 'package:contrast_coach/presentation/state/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Appearance renders header + accent palette + v4 rows', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const AppearanceScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.textContaining('Dark mode'), findsOneWidget);
    expect(find.textContaining('Match system'), findsOneWidget);
    expect(find.text('Accent color'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
