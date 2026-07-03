import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/share/share_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShareCardScreen renders without crashing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const ShareCardScreen(),
      ),
    );
    // Don't pumpAndSettle — DB load is async and might pump RouterContext.
    await tester.pump(const Duration(milliseconds: 50));
    // Header may be "No recent session" or share button — just assert no exception
    expect(find.byType(ShareCardScreen), findsOneWidget);
  });
}
