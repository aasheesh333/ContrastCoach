import 'package:contrast_coach/presentation/screens/settings/appearance_screen.dart';
import 'package:contrast_coach/presentation/state/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Appearance renders header + accent palette', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(home: AppearanceScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Appearance'), findsOneWidget);
    // The accent palette contains heat color in tokens
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
