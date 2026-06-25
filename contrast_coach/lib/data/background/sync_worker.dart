import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';

import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/notifications/notification_service.dart';
import 'package:contrast_coach/data/remote/firebase/firebase_config.dart';
import 'package:contrast_coach/data/remote/firebase/firestore_api.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';

import 'package:workmanager/src/options.dart' as wm_options;

const String syncTaskName = 'syncSessions';
const String streakReminderTaskName = 'streakReminder';
const String optimalTimingTaskName = 'optimalTiming';
const String sleepInsightTaskName = 'sleepInsight';

@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final options = FirebaseConfig.currentPlatform;
      if (options != null) {
        await Firebase.initializeApp(options: options);
      }
      await AppPreferences.init();

      switch (task) {
        case syncTaskName:
          return await _doSync();
        case streakReminderTaskName:
          return await _doStreakReminder();
        case optimalTimingTaskName:
          return await _doOptimalTiming();
        case sleepInsightTaskName:
          return await _doSleepInsight();
        default:
          return true;
      }
    } catch (_) {
      return false;
    }
  });
}

Future<bool> _doSync() async {
  try {
    final db = await DatabaseProvider.instance();
    final firestore = FirestoreApi(FirebaseFirestore.instance);
    final repo = SessionRepositoryImpl(db, firestoreApi: firestore);

    final allResult = await repo.getAll();
    if (allResult.isOk) {
      final ok = allResult as Ok;
      final sessions = ok.value as List;
      final userIds = sessions
          .map((s) => (s as dynamic).userId as String?)
          .where((id) => id != null)
          .toSet()
          .cast<String>();
      for (final uid in userIds) {
        await repo.syncToRemote(uid);
      }
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _doStreakReminder() async {
  try {
    if (!AppPreferences.notificationsEnabled) return true;
    final db = await DatabaseProvider.instance();
    final repo = SessionRepositoryImpl(db);
    final allResult = await repo.getAll();
    if (!allResult.isOk) return true;
    final sessions = (allResult as Ok).value as List;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final hasSessionToday = sessions.any((s) {
      final started = (s as dynamic).startedAt as DateTime;
      return DateTime(started.year, started.month, started.day) == todayDate;
    });
    if (!hasSessionToday) {
      int streakDays = 0;
      for (int i = 1; i <= 365; i++) {
        final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
        final hasSession = sessions.any((s) {
          final started = (s as dynamic).startedAt as DateTime;
          return DateTime(started.year, started.month, started.day) == date;
        });
        if (hasSession) {
          streakDays++;
        } else {
          break;
        }
      }
      await NotificationService().showStreakReminder(streakDays: streakDays);
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _doOptimalTiming() async {
  try {
    if (!AppPreferences.notificationsEnabled) return true;
    await NotificationService().showOptimalTiming(timeOfDay: 'morning');
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _doSleepInsight() async {
  try {
    if (!AppPreferences.notificationsEnabled) return true;
    await NotificationService().showSleepInsight(insight: 'Good sleep boosts recovery scores.');
    return true;
  } catch (_) {
    return false;
  }
}

class SyncWorker {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Workmanager().initialize(backgroundCallback, isInDebugMode: false);
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: wm_options.ExistingWorkPolicy.keep,
      );
      await _registerNotificationTasks();
      _initialized = true;
    } catch (_) {
      // Workmanager init is best-effort
    }
  }

  static Future<void> _registerNotificationTasks() async {
    try {
      await Workmanager().registerPeriodicTask(
        streakReminderTaskName,
        streakReminderTaskName,
        frequency: const Duration(hours: 24),
        constraints: Constraints(networkType: NetworkType.not_required),
        existingWorkPolicy: wm_options.ExistingWorkPolicy.keep,
        initialDelay: const Duration(hours: 20),
      );
    } catch (_) {}

    try {
      await Workmanager().registerPeriodicTask(
        optimalTimingTaskName,
        optimalTimingTaskName,
        frequency: const Duration(hours: 72),
        constraints: Constraints(networkType: NetworkType.not_required),
        existingWorkPolicy: wm_options.ExistingWorkPolicy.keep,
      );
    } catch (_) {}

    try {
      await Workmanager().registerPeriodicTask(
        sleepInsightTaskName,
        sleepInsightTaskName,
        frequency: const Duration(hours: 168),
        constraints: Constraints(networkType: NetworkType.not_required),
        existingWorkPolicy: wm_options.ExistingWorkPolicy.keep,
      );
    } catch (_) {}
  }
}
