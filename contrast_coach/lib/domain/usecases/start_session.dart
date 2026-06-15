import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

typedef AnalyticsTracker = Future<void> Function(String eventName, Map<String, dynamic> data);

class StartSession {
  StartSession({
    required SessionRepository sessions,
    required ProtocolRepository protocols,
    AnalyticsTracker? onStart,
    Uuid? uuid,
  })  : _sessions = sessions,
        _protocols = protocols,
        _onStart = onStart,
        _uuid = uuid ?? const Uuid();

  final SessionRepository _sessions;
  final ProtocolRepository _protocols;
  final AnalyticsTracker? _onStart;
  final Uuid _uuid;

  Future<Result<Session, AppException>> call({
    required String protocolId,
    required Goal goal,
  }) async {
    final protocolResult = await _protocols.getById(protocolId);
    if (protocolResult is Err) {
      return Err((protocolResult as Err).error);
    }
    final protocol = (protocolResult as Ok<Protocol?, AppException>).value;
    if (protocol == null) {
      return Err(ValidationException('Unknown protocol: $protocolId'));
    }

    final now = DateTime.now();
    final session = Session(
      id: _uuid.v4(),
      protocolId: protocolId,
      goal: goal,
      startedAt: now,
      totalPlannedDuration: protocol.totalDuration,
      totalActualDuration: Duration.zero,
      roundsCompleted: 0,
      protocolRounds: protocol.rounds,
      createdAt: now,
      updatedAt: now,
    );

    final saveResult = await _sessions.save(session);
    if (saveResult is Err) {
      return Err((saveResult as Err).error);
    }
    await _onStart?.call('session_started', {'protocol_id': protocolId});
    return Ok(session);
  }
}
