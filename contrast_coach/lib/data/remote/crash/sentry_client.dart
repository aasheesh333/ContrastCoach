import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/data/background/sync_worker.dart';
import 'package:contrast_coach/data/notifications/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryBootstrap {
  static Future<void> runWithSentry() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.init();
    await NotificationService().init();
    await SyncWorker.init();
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
          return event;
        };
      },
      appRunner: () => runApp(const ContrastCoachApp()),
    );
  }
}
