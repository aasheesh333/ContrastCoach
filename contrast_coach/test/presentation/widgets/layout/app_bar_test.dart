import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('back button shows chevron and circle border when enabled',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          appBar: ContrastAppBar(title: 'Test', showBackButton: true),
        ),
      ),
    );

    expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
    final chevronFinder = find.byIcon(LucideIcons.chevronLeft);
    final materialFinder = find.ancestor(
      of: chevronFinder,
      matching: find.byType(Material),
    );
    final materials = tester.widgetList<Material>(materialFinder);
    expect(
      materials.any((m) => m.shape is CircleBorder),
      isTrue,
      reason: 'A 36dp circle Material with line border should wrap the chevron',
    );
    final sizedBoxes = tester.widgetList<SizedBox>(
      find.ancestor(
        of: chevronFinder,
        matching: find.byType(SizedBox),
      ),
    );
    expect(
      sizedBoxes.any(
        (s) => s.width == 36 && s.height == 36,
      ),
      isTrue,
      reason: 'A 36x36 SizedBox should size the circle button',
    );
  });
}
