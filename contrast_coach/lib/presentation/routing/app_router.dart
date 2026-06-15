import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:contrast_coach/presentation/routing/route_names.dart';
import 'package:contrast_coach/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:contrast_coach/presentation/screens/home/home_screen.dart';
import 'package:contrast_coach/presentation/screens/session/active_session_screen.dart';
import 'package:contrast_coach/presentation/screens/session/session_summary_screen.dart';
import 'package:contrast_coach/presentation/screens/streak/streak_calendar_screen.dart';
import 'package:contrast_coach/presentation/screens/insights/insights_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/settings_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/health_connect_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/privacy_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/data_export_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/delete_account_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/about_screen.dart';
import 'package:contrast_coach/presentation/screens/health_rationale/health_permission_rationale_screen.dart';
import 'package:contrast_coach/presentation/screens/voice_rationale/voice_permission_rationale_screen.dart';
import 'package:contrast_coach/presentation/screens/paywall/paywall_screen.dart';
import 'package:contrast_coach/presentation/screens/auth/sign_in_screen.dart';
import 'package:contrast_coach/presentation/screens/auth/sign_up_screen.dart';
import 'package:contrast_coach/presentation/screens/shell/home_shell.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter build({required bool isOnboarded, required bool isAuthed}) {
    return GoRouter(
      initialLocation: isOnboarded ? (isAuthed ? '/home' : '/sign-in') : '/onboarding',
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: '/onboarding',
          name: RouteNames.onboarding,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          name: RouteNames.signIn,
          builder: (_, __) => const SignInScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          name: RouteNames.signUp,
          builder: (_, __) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/paywall',
          name: RouteNames.paywall,
          builder: (_, __) => const PaywallScreen(),
        ),
        GoRoute(
          path: '/health/rationale',
          name: RouteNames.healthRationale,
          builder: (_, __) => const HealthPermissionRationaleScreen(),
        ),
        GoRoute(
          path: '/voice/rationale',
          name: RouteNames.voiceRationale,
          builder: (_, __) => const VoicePermissionRationaleScreen(),
        ),
        ShellRoute(
          builder: (_, __, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/streak',
              name: RouteNames.streak,
              builder: (_, __) => const StreakCalendarScreen(),
            ),
            GoRoute(
              path: '/insights',
              name: RouteNames.insights,
              builder: (_, __) => const InsightsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/session',
          name: RouteNames.session,
          builder: (_, __) => const ActiveSessionScreen(),
        ),
        GoRoute(
          path: '/summary/:sessionId',
          name: RouteNames.summary,
          builder: (_, s) => SessionSummaryScreen(sessionId: s.pathParameters['sessionId']!),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (_, __) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'health',
              name: RouteNames.settingsHealth,
              builder: (_, __) => const HealthConnectScreen(),
            ),
            GoRoute(
              path: 'privacy',
              name: RouteNames.settingsPrivacy,
              builder: (_, __) => const PrivacyScreen(),
            ),
            GoRoute(
              path: 'export',
              name: RouteNames.settingsExport,
              builder: (_, __) => const DataExportScreen(),
            ),
            GoRoute(
              path: 'delete',
              name: RouteNames.settingsDelete,
              builder: (_, __) => const DeleteAccountScreen(),
            ),
            GoRoute(
              path: 'about',
              name: RouteNames.settingsAbout,
              builder: (_, __) => const AboutScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      ),
    );
  }
}
