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
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:contrast_coach/data/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await AppPreferences.init();

  // Parallelize independent init steps for faster startup
  await Future.wait([
    _initFirebaseSafely(),
    _initNotificationsSafely(),
    _initCrashlyticsSafely(),
  ]);

  // These depend on Firebase being initialized
  await AnalyticsApi.syncCollectionEnabled();
  await SyncWorker.init();
  await RevenueCatBootstrap.init();

  await _restoreOnLaunch();
  runApp(const ContrastCoachApp());
}

Future<void> _initFirebaseSafely() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
    }
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
}

Future<void> _initNotificationsSafely() async {
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }
}

Future<void> _initCrashlyticsSafely() async {
  try {
    await CrashlyticsClient().init();
  } catch (e) {
    debugPrint('Crashlytics init failed: $e');
  }
}

Future<void> _restoreOnLaunch() async {
  try {
    final repo = SubscriptionRepositoryImpl();
    await repo.restore();
  } catch (_) {
    // best-effort restore on launch
  }
}
