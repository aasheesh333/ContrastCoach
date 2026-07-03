import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/widgets/widgets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Widgets screen renders v4 chrome (title, 3 widget preview cards, Add to home screen button)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const WidgetsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Home-screen widgets'), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
    expect(find.textContaining('🔥 7 days'), findsOneWidget);
    expect(find.text('RECOVERY'), findsOneWidget);
    expect(find.textContaining('82 · Strong'), findsOneWidget);
    expect(find.text('NEXT SESSION'), findsOneWidget);
    expect(find.textContaining('Standard · 26 min'), findsOneWidget);
    expect(find.text('Add to home screen'), findsOneWidget);
  });
}
