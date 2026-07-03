import 'package:contrast_coach/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash renders brand wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('ContrastCoach'), findsOneWidget);
    expect(find.text('HEAT. COLD. REPEAT.'), findsOneWidget);
  });
}
