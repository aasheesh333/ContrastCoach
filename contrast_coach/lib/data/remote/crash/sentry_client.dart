import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryBootstrap {
  static Future<void> runWithSentry() async {
    final dsn = EnvConfig.sentryDsn;
    if (dsn == null || dsn.isEmpty) {
      runApp(const ContrastCoachApp());
      return;
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 0.1;
        options.beforeSend = (event, hint) {
          event.user = null;
          event.tags?.remove('health_data');
          event.tags?.remove('user_id');
          return event;
        };
        options.beforeBreadcrumb = (breadcrumb, hint) {
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
