import 'dart:async';

import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/background/sync_worker.dart';
import 'package:contrast_coach/data/remote/crash/crashlytics_client.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/remote/firebase/firebase_config.dart';
import 'package:contrast_coach/data/remote/subscription/revenue_cat_client.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:contrast_coach/data/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await AppPreferences.init();

  await Future.wait([
    _initFirebaseSafely(),
    _initNotificationsSafely(),
    _initCrashlyticsSafely(),
  ]);

  await AnalyticsApi.syncCollectionEnabled();
  await _initSyncWorkerSafely();
  await _initRevenueCatSafely();

  await _restoreOnLaunch();
  runApp(const ContrastCoachApp());
}

void _logInitFailure(String service, Object error) {
  if (kDebugMode) {
    debugPrint('$service init failed: $error');
  } else {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        StackTrace.current,
        reason: '$service init failed',
        fatal: false,
      );
    } catch (_) {}
  }
}

Future<void> _initFirebaseSafely() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
    }
  } catch (e) {
    _logInitFailure('Firebase', e);
  }
}

Future<void> _initNotificationsSafely() async {
  try {
    await NotificationService().init();
  } catch (e) {
    _logInitFailure('Notification', e);
  }
}

Future<void> _initCrashlyticsSafely() async {
  try {
    await CrashlyticsClient().init();
  } catch (e) {
    _logInitFailure('Crashlytics', e);
  }
}

Future<void> _restoreOnLaunch() async {
  try {
    final repo = SubscriptionRepositoryImpl();
    await repo.restore();
  } catch (_) {}
}

Future<void> _initSyncWorkerSafely() async {
  try {
    await SyncWorker.init();
  } catch (e) {
    _logInitFailure('SyncWorker', e);
  }
}

Future<void> _initRevenueCatSafely() async {
  try {
    await RevenueCatBootstrap.init();
  } catch (e) {
    _logInitFailure('RevenueCat', e);
  }
}
