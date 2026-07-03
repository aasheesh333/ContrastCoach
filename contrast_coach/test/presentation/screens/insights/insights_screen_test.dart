import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/insights/insights_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Pro paywall gate when tier resolves to free in test env',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const InsightsScreen(),
      ),
    );
    // Let the async _load() complete. _sharedState.tier is free by default;
    // FeatureGating.canUseInsights(free) is false → paywall gate renders.
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Insights are part of Pro.'), findsOneWidget);
    expect(find.text('See Pro plans'), findsOneWidget);
  });
}
