import 'package:flutter/material.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
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
import 'package:contrast_coach/presentation/screens/custom_protocol/custom_protocol_builder_screen.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter build({
    required bool isOnboarded,
    required bool isAuthed,
    Listenable? refreshListenable,
  }) {
    return GoRouter(
      initialLocation: isOnboarded ? (isAuthed ? '/home' : '/sign-in') : '/onboarding',
      debugLogDiagnostics: false,
      refreshListenable: refreshListenable,
      redirect: (_, state) {
        final path = state.uri.path;
        final publicRoutes = {'/sign-in', '/sign-up', '/onboarding', '/terms', '/privacy'};
        final isPublicRoute = publicRoutes.contains(path);

        if (!isOnboarded) {
          return path == '/onboarding' ? null : '/onboarding';
        }

        if (!isAuthed) {
          return isPublicRoute ? null : '/sign-in';
        }

        if (isPublicRoute && path != '/terms' && path != '/privacy') {
          return '/home';
        }

        return null;
      },
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
          path: '/terms',
          name: RouteNames.terms,
          builder: (_, __) => _LegalScreen(title: 'Terms of Service', body: _termsBody),
        ),
        GoRoute(
          path: '/privacy',
          name: RouteNames.privacyPolicy,
          builder: (_, __) => _LegalScreen(title: 'Privacy Policy', body: _privacyBody),
        ),
        GoRoute(
          path: '/paywall',
          name: RouteNames.paywall,
          builder: (_, __) => const PaywallScreen(),
        ),
        GoRoute(
          path: '/protocol/custom',
          name: RouteNames.customProtocol,
          builder: (_, __) => const CustomProtocolBuilderScreen(),
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
          path: '/session/:protocolId',
          name: RouteNames.session,
          builder: (_, s) => ActiveSessionScreen(protocolId: s.pathParameters['protocolId']!),
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

class _LegalScreen extends StatelessWidget {
  const _LegalScreen({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(body, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, color: AppColors.darkGray, height: 1.7)),
      ),
    );
  }
}

const String _termsBody = '''
Terms of Service

Last updated: 2024

By using ContrastCoach, you agree to these terms.

1. Acceptance of Terms
By downloading and using ContrastCoach, you accept these Terms of Service and our Privacy Policy.

2. Description of Service
ContrastCoach provides guided contrast therapy session timers and wellness tracking tools. It is not a medical device and should not be used as a substitute for professional medical advice.

3. User Accounts
You may create an account to sync your data across devices. You are responsible for maintaining the confidentiality of your account credentials.

4. Subscription Payments
Pro features are available via monthly, yearly, or lifetime subscriptions. Payments are processed through the Google Play Store. Refunds are subject to Google Play's refund policy.

5. Data & Privacy
We collect minimal data necessary to provide the service. See our Privacy Policy for details.

6. Disclaimer of Warranties
ContrastCoach is provided "as is" without warranties of any kind. Always consult a healthcare professional before beginning any contrast therapy routine.

7. Limitation of Liability
ContrastCoach shall not be liable for any damages arising from your use of the app.

8. Changes to Terms
We may update these terms from time to time. Continued use constitutes acceptance of changes.

9. Contact
For questions, contact us at support@contrastcoach.app.
''';

const String _privacyBody = '''
Privacy Policy

Last updated: 2024

ContrastCoach ("we", "us", "our") respects your privacy and is committed to protecting your personal data.

1. Information We Collect
- Account information: email address (for authentication)
- Session data: contrast therapy session logs (stored locally and optionally synced to cloud)
- Health data: heart rate, HRV, sleep (optional, via Health Connect, read-only)
- Usage analytics: anonymized app usage events (if analytics not opted out)

2. How We Use Your Information
- To provide and improve the contrast therapy guidance service
- To sync your session data across devices (Pro users)
- To calculate recovery scores and insights
- To send you session reminders (if notifications enabled)

3. Data Storage
- All session data is stored locally on your device using encrypted SQLCipher database
- Cloud sync uses Firebase Firestore with encryption in transit and at rest
- Health Connect data is read-only and never stored on our servers

4. Data Sharing
We do NOT sell, rent, or share your personal data with third parties for marketing purposes.

5. Your Rights
- You may export all your data at any time via Settings > Export Data
- You may delete your account and all associated data via Settings > Delete Account
- You may revoke Health Connect permissions at any time via Android settings

6. Data Retention
- Local data persists until you delete your account or uninstall the app
- Cloud data is deleted within 30 days of account deletion

7. Children's Privacy
ContrastCoach is not intended for children under 13.

8. Security
We use industry-standard encryption (SQLCipher, TLS 1.3) to protect your data.

9. Changes to This Policy
We may update this policy from time to time. We will notify you of significant changes.

10. Contact
For privacy inquiries, contact us at privacy@contrastcoach.app.
''';
