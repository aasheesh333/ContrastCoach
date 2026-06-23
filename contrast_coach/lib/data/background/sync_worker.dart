import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';

import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/remote/firebase/firebase_config.dart';
import 'package:contrast_coach/data/remote/firebase/firestore_api.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';

import 'package:workmanager/src/options.dart' as wm_options;

const String syncTaskName = 'syncSessions';

@pragma('vm:entry-point')
void syncCallback() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
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
      await db.close();
      return true;
    } catch (_) {
      return false;
    }
  });
}

class SyncWorker {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Workmanager().initialize(syncCallback, isInDebugMode: false);
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: wm_options.ExistingWorkPolicy.keep,
      );
      _initialized = true;
    } catch (_) {
      // Workmanager init is best-effort
    }
  }
}
