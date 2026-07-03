import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('back button shows chevron glyph in 12-radius rounded square '
      'when enabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          appBar: ContrastAppBar(title: 'Test', showBackButton: true),
        ),
      ),
    );

    expect(find.text('‹'), findsOneWidget);
    final chevronFinder = find.text('‹');
    final materialFinder = find.ancestor(
      of: chevronFinder,
      matching: find.byType(Material),
    );
    final materials = tester.widgetList<Material>(materialFinder);
    expect(
      materials.any((m) {
        final shape = m.shape;
        if (shape is! RoundedRectangleBorder) return false;
        final r = shape.borderRadius;
        return r.topLeft == const Radius.circular(12) &&
            r.topRight == const Radius.circular(12) &&
            r.bottomLeft == const Radius.circular(12) &&
            r.bottomRight == const Radius.circular(12);
      }),
      isTrue,
      reason: 'A 12-radius rounded square Material with line border should '
          'wrap the chevron glyph (v4 spec replaces 36dp circle).',
    );
  });

  testWidgets('title text uses 19/w800/ls-.4 v4 spec typography',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          appBar: ContrastAppBar(title: 'Insights'),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Insights'));
    expect(title.style?.fontSize, 19);
    expect(title.style?.fontWeight, FontWeight.w800);
    expect(title.style?.letterSpacing, -0.4);
  });
}
