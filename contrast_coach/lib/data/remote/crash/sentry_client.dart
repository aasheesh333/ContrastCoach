import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryBootstrap {
  const SentryBootstrap._();

  static Future<void> runWithSentry() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dsn = EnvConfig.sentryDsn;
    if (dsn == null || dsn.isEmpty) {
      runApp(const ContrastCoachApp());
      return;
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 0.1;
        options.beforeSend = (SentryEvent event, Hint hint) {
          return event.copyWith(
            user: const SentryUser(id: null, username: null, email: null, ipAddress: null),
          );
        };
        options.beforeBreadcrumb = (SentryBreadcrumb? breadcrumb, Hint? hint) {
          if (breadcrumb == null) return null;
          if (breadcrumb.message?.toLowerCase().contains('voice') == true) {
            return null;
          }
          return breadcrumb;
        };
      },
      appRunner: () => runApp(const ContrastCoachApp()),
    );
  }
}
