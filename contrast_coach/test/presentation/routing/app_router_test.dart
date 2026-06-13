import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('initial route is onboarding when not onboarded', (tester) async {
    final router = AppRouter.build(isOnboarded: false, isAuthed: false);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/onboarding');
  });

  testWidgets('initial route is sign-in when onboarded but not authed', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: false);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/sign-in');
  });

  testWidgets('initial route is home when onboarded and authed', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: true);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });
}
