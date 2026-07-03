import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/presentation/screens/insights/insights_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders shimmer skeleton on initial load (real DB unavailable in test)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const InsightsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ShimmerLoading), findsOneWidget);
  });
}
