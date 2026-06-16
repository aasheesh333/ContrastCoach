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
    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.tracesSampleRate = 0.1;
          options.beforeSend = (event, hint) {
            try {
              event.tags?.remove('user_id');
              event.tags?.remove('health_data');
              event.tags?.remove('rawHeartRate');
              event.tags?.remove('rawHrv');
              event.tags?.remove('rawSleep');
              event.extra?.remove('voiceTranscript');
              event.extra?.remove('healthSnapshot');
            } catch (_) {}
            return event;
          };
          options.beforeBreadcrumb = (breadcrumb, hint) {
            if (breadcrumb == null) return null;
            final msg = (breadcrumb.message ?? '').toLowerCase();
            if (msg.contains('voice') || msg.contains('transcript')) {
              return null;
            }
            if (msg.contains('health') || msg.contains('hrv') || msg.contains('sleep')) {
              return null;
            }
            return breadcrumb;
          };
        },
        appRunner: () => runApp(const ContrastCoachApp()),
      );
    } catch (_) {
      runApp(const ContrastCoachApp());
    }
  }
}
