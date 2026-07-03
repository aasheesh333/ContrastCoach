import 'dart:async';

import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/background/sync_worker.dart';
import 'package:contrast_coach/data/remote/crash/crashlytics_client.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/remote/firebase/firebase_config.dart';
import 'package:contrast_coach/data/remote/subscription/revenue_cat_client.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:contrast_coach/data/notifications/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _initTimeout = Duration(seconds: 8);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initEnvSafely();
  await _initPreferencesSafely();

  await Future.wait([
    _initFirebaseSafely(),
    _initNotificationsSafely(),
    _initCrashlyticsSafely(),
  ]);

  await _safeTimeout(AnalyticsApi.syncCollectionEnabled());
  await _initSyncWorkerSafely();
  await _initRevenueCatSafely();

  await _restoreOnLaunch().timeout(_initTimeout, onTimeout: () {});
  runApp(const ProviderScope(child: ContrastCoachApp()));
}

Future<void> _safeTimeout(Future<void> future) {
  return future.timeout(_initTimeout, onTimeout: () {});
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

Future<void> _initEnvSafely() async {
  try {
    await EnvConfig.init().timeout(_initTimeout);
  } catch (e) {
    _logInitFailure('EnvConfig', e);
  }
}

Future<void> _initPreferencesSafely() async {
  try {
    await AppPreferences.init().timeout(_initTimeout);
  } catch (e) {
    _logInitFailure('AppPreferences', e);
  }
}

Future<void> _initFirebaseSafely() async {
  try {
    if (Firebase.apps.isEmpty) {
      final options = FirebaseConfig.currentPlatform;
      if (options == null) {
        _logInitFailure('Firebase', 'API key not configured -- skipping Firebase init');
        return;
      }
      await Firebase.initializeApp(options: options)
          .timeout(_initTimeout);
    }
  } catch (e) {
    _logInitFailure('Firebase', e);
  }
}

Future<void> _initNotificationsSafely() async {
  try {
    await NotificationService().init().timeout(_initTimeout);
  } catch (e) {
    _logInitFailure('Notification', e);
  }
}

Future<void> _initCrashlyticsSafely() async {
  try {
    await CrashlyticsClient().init().timeout(_initTimeout);
  } catch (e) {
    _logInitFailure('Crashlytics', e);
  }
}

Future<void> _restoreOnLaunch() async {
  try {
    final repo = SubscriptionRepositoryImpl()
      ..bindSharedState(SharedSubscriptionState.instance);
    final result = await repo.currentTier();
    if (result is Ok<SubscriptionTier, AppException>) {
      SharedSubscriptionState.instance.notify(result.value);
    }
  } catch (_) {}
}

Future<void> _initSyncWorkerSafely() async {
  try {
    await SyncWorker.init().timeout(_initTimeout);
  } catch (e) {
    _logInitFailure('SyncWorker', e);
  }
}

Future<void> _initRevenueCatSafely() async {
  try {
    await RevenueCatBootstrap.init().timeout(_initTimeout);
  } catch (e) {
    _logInitFailure('RevenueCat', e);
  }
}
