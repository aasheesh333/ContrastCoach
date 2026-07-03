import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (_, __) => const SignInScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (_, __) => const Scaffold(body: Text('sign-up')),
        ),
      ],
    );
  });

  Widget buildHarness({ThemeData? theme}) => MaterialApp.router(
        theme: theme ?? AppTheme.light(),
        routerConfig: router,
      );

  testWidgets('renders a Google OAuth row and an Apple OAuth row above the '
      'OR divider', (tester) async {
    await tester.pumpWidget(buildHarness());
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
  });

  testWidgets('OAuth rows come before the email/password fields',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    final googleFinder = find.text('Continue with Google');
    final emailFinder = find.text('Email');
    expect(googleFinder, findsOneWidget);
    expect(emailFinder, findsOneWidget);

    final googleY = tester.getTopLeft(googleFinder).dy;
    final emailY = tester.getTopLeft(emailFinder).dy;
    expect(googleY, lessThan(emailY));
  });

  testWidgets('Apple OAuth row precedes the OR divider, divider precedes '
      'Email field', (tester) async {
    await tester.pumpWidget(buildHarness());

    final appleFinder = find.text('Continue with Apple');
    final dividerFinder = find.text('OR');
    final emailFinder = find.text('Email');

    final appleY = tester.getTopLeft(appleFinder).dy;
    final dividerY = tester.getTopLeft(dividerFinder).dy;
    final emailY = tester.getTopLeft(emailFinder).dy;

    expect(appleY, lessThan(dividerY));
    expect(dividerY, lessThan(emailY));
  });

  testWidgets('headline is 24/w800/ls-.5 per v4 spec', (tester) async {
    await tester.pumpWidget(buildHarness());
    final title = tester.widget<Text>(find.text('Welcome back'));
    expect(title.style?.fontSize, 24);
    expect(title.style?.fontWeight, FontWeight.w800);
    expect(title.style?.letterSpacing, -0.5);
  });

  testWidgets('subtitle reads "Recover smarter with every session" 13/w500',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    final sub = tester.widget<Text>(
      find.text('Recover smarter with every session'),
    );
    expect(sub.style?.fontSize, 13);
    expect(sub.style?.fontWeight, FontWeight.w500);
  });

  testWidgets('drops the medical disclaimer completely', (tester) async {
    await tester.pumpWidget(buildHarness());
    const disclaimer =
        'This app is for general wellness tracking and does not provide '
        'medical advice';
    expect(find.textContaining(disclaimer), findsNothing);
  });

  testWidgets('drops the Forgot password link', (tester) async {
    await tester.pumpWidget(buildHarness());
    expect(find.text('Forgot password?'), findsNothing);
  });

  testWidgets('footer reads "New here? Create account" (12/w600)',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    final left = tester.widget<Text>(find.text('New here? '));
    final right = tester.widget<Text>(find.text('Create account'));
    expect(left.style?.fontSize, 12);
    expect(left.style?.fontWeight, FontWeight.w600);
    expect(right.style?.fontSize, 12);
    expect(right.style?.fontWeight, FontWeight.w600);
    expect(right.style?.color, const Color(0xFFFF6B35));
  });
}
