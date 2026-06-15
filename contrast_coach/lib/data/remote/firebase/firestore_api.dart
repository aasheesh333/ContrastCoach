import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';

/// Thin wrapper around the per-user `sessions` Firestore collection.
///
/// Only computed metrics are persisted — never raw HR/HRV/sleep values.
class FirestoreApi {
  /// Creates a [FirestoreApi] backed by the supplied [FirebaseFirestore].
  FirestoreApi(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _sessions(String userId) =>
      _db.collection('users').doc(userId).collection('sessions');

  /// Uploads [session] (merge) to the user's session document.
  Future<void> uploadSession(String userId, Session session) async {
    final json = _sessionToJson(session)
      ..['clientUpdatedAt'] = FieldValue.serverTimestamp();
    await _sessions(userId).doc(session.id).set(json, SetOptions(merge: true));
  }

  /// Downloads all sessions for [userId], newest first.
  ///
  /// [since] is reserved for future incremental sync; currently unused.
  Future<List<Session>> downloadSessions(
    String userId, {
    DateTime? since,
  }) async {
    final query = _sessions(userId).orderBy('startedAt', descending: true);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _sessionFromJson(doc.data())).toList();
  }

  Map<String, dynamic> _sessionToJson(Session s) {
    return <String, dynamic>{
      'id': s.id,
      'protocolId': s.protocolId,
      'goal': s.goal.name,
      'startedAt': Timestamp.fromDate(s.startedAt),
      'endedAt': s.endedAt != null ? Timestamp.fromDate(s.endedAt!) : null,
      'totalPlannedDurationSec': s.totalPlannedDuration.inSeconds,
      'totalActualDurationSec': s.totalActualDuration.inSeconds,
      'roundsCompleted': s.roundsCompleted,
      'protocolRounds': s.protocolRounds,
      'recoveryScore': s.recoveryScore,
      'notes': s.notes,
      // Only computed health metrics, never raw values.
      'healthDataSnapshot': s.healthDataSnapshot,
      'userId': s.userId,
    };
  }

  Session _sessionFromJson(Map<String, dynamic> json) {
    final startedAt = (json['startedAt'] as Timestamp).toDate();
    final endedAtRaw = json['endedAt'];
    return Session(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      protocolId: json['protocolId'] as String,
      goal: Goal.fromString((json['goal'] as String?) ?? 'recovery'),
      startedAt: startedAt,
      endedAt: endedAtRaw is Timestamp ? endedAtRaw.toDate() : null,
      totalPlannedDuration:
          Duration(seconds: (json['totalPlannedDurationSec'] as int?) ?? 0),
      totalActualDuration:
          Duration(seconds: (json['totalActualDurationSec'] as int?) ?? 0),
      roundsCompleted: (json['roundsCompleted'] as int?) ?? 0,
      protocolRounds: (json['protocolRounds'] as int?) ?? 1,
      recoveryScore: (json['recoveryScore'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      healthDataSnapshot:
          (json['healthDataSnapshot'] as Map?)?.cast<String, dynamic>(),
      isSynced: true,
      createdAt: startedAt,
      updatedAt: DateTime.now(),
    );
  }
}
