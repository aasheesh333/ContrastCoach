import 'dart:async';

import 'package:contrast_coach/data/remote/crash/sentry_client.dart';
import 'package:contrast_coach/data/remote/subscription/revenue_cat_client.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';

Future<void> main() async {
  await SentryBootstrap.runWithSentry();
  await RevenueCatBootstrap.init();
  unawaited(_restoreOnLaunch());
}

Future<void> _restoreOnLaunch() async {
  try {
    final repo = SubscriptionRepositoryImpl();
    await repo.restore();
  } catch (_) {
    // best-effort restore on launch
  }
}
