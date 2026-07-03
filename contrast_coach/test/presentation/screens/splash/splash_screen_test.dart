import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Splash renders brand wordmark', (tester) async {
    AppPreferences.setOnboardingComplete(true);
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: SizedBox.shrink())),
        GoRoute(path: '/onboarding', builder: (_, __) => const Scaffold(body: SizedBox.shrink())),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: Router(routerConfig: router)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('ContrastCoach'), findsOneWidget);
    expect(find.text('HEAT. COLD. REPEAT.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));
  });
}
