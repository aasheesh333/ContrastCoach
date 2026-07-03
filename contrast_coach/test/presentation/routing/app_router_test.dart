import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:contrast_coach/presentation/routing/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('initial route is onboarding when not onboarded', (tester) async {
    final router = AppRouter.build(isOnboarded: false, isAuthed: false, firebaseAvailable: true);
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
    final router = AppRouter.build(isOnboarded: true, isAuthed: false, firebaseAvailable: true);
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
    final router = AppRouter.build(isOnboarded: true, isAuthed: true, firebaseAvailable: true);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });

  testWidgets('initial route is home when Firebase unavailable', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: true, firebaseAvailable: false);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });

  testWidgets('sign-in redirects to home when Firebase unavailable', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: false, firebaseAvailable: false);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });

  testWidgets('/explore route builds inside the ShellRoute', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: true, firebaseAvailable: true);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byType(Navigator));
    GoRouter.of(context).go('/explore');
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/explore');
    expect(find.text('Explore'), findsWidgets);
  });

  testWidgets('/coach route builds inside the ShellRoute', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: true, firebaseAvailable: true);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byType(Navigator));
    GoRouter.of(context).go('/coach');
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/coach');
    expect(find.text('Coach'), findsWidgets);
  });

  testWidgets('/settings/streak builds after move under /settings', (tester) async {
    final router = AppRouter.build(isOnboarded: true, isAuthed: true, firebaseAvailable: true);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byType(Navigator));
    GoRouter.of(context).go('/settings/streak');
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/settings/streak');
  });
}
