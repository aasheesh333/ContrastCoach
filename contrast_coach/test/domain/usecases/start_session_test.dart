import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/start_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProtocolRepo extends Mock implements ProtocolRepository {}
class _MockSessionRepo extends Mock implements SessionRepository {}

class FakeSession extends Fake implements Session {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSession());
  });

  late _MockProtocolRepo protocols;
  late _MockSessionRepo sessions;

  setUp(() {
    protocols = _MockProtocolRepo();
    sessions = _MockSessionRepo();
  });

  final tProtocol = Protocol(
    id: 'p1', name: 'Test', description: 'x',
    category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
    rounds: 2,
    phases: const [
      PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 10)),
      PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2)),
    ],
  );

  test('returns Err for unknown protocol', () async {
    when(() => protocols.getById('p1')).thenAnswer((_) async => const Ok<Protocol?, AppException>(null));
    final uc = StartSession(sessions: sessions, protocols: protocols);
    final result = await uc(protocolId: 'p1', goal: Goal.recovery);
    expect(result.isErr, isTrue);
  });

  test('saves a session and returns it', () async {
    when(() => protocols.getById('p1')).thenAnswer((_) async => Ok<Protocol?, AppException>(tProtocol));
    when(() => sessions.save(any())).thenAnswer((inv) async {
      final s = inv.positionalArguments.first as Session;
      return Ok<Session, AppException>(s);
    });

    final uc = StartSession(sessions: sessions, protocols: protocols);
    final result = await uc(protocolId: 'p1', goal: Goal.energy);
    expect(result.isOk, isTrue);
    final s = (result as Ok).value;
    expect(s.protocolId, 'p1');
    expect(s.goal, Goal.energy);
    expect(s.totalPlannedDuration.inMinutes, greaterThan(0));
  });

  test('forwards analytics event', () async {
    when(() => protocols.getById('p1')).thenAnswer((_) async => Ok<Protocol?, AppException>(tProtocol));
    when(() => sessions.save(any())).thenAnswer((inv) async {
      return Ok<Session, AppException>(inv.positionalArguments.first as Session);
    });

    var captured = '';
    final uc = StartSession(
      sessions: sessions,
      protocols: protocols,
      onStart: (name, _) async {
        captured = name;
      },
    );
    await uc(protocolId: 'p1', goal: Goal.recovery);
    expect(captured, 'session_started');
  });
}
