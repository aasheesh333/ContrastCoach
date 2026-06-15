import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/end_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepo extends Mock implements SessionRepository {}

class FakeSession extends Fake implements Session {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSession());
  });

  late _MockSessionRepo sessions;

  setUp(() {
    sessions = _MockSessionRepo();
  });

  test('end session updates actual duration, rounds, and computes score', () async {
    final start = DateTime(2026, 6, 13, 7, 0);
    final end = DateTime(2026, 6, 13, 7, 30);
    final existing = Session(
      id: 's1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: start,
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: Duration.zero,
      roundsCompleted: 0,
      protocolRounds: 3,
      createdAt: start,
      updatedAt: start,
    );
    when(() => sessions.getById('s1')).thenAnswer((_) async => Ok<Session?, AppException>(existing));
    when(() => sessions.save(any())).thenAnswer((inv) async {
      return Ok<Session, AppException>(inv.positionalArguments.first as Session);
    });

    final uc = EndSession(sessions: sessions, streakProvider: () => 0);
    final result = await uc(
      sessionId: 's1',
      endedAt: end,
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
    );

    expect(result.isOk, isTrue);
    final s = (result as Ok).value;
    expect(s.endedAt, end);
    expect(s.totalActualDuration.inMinutes, 30);
    expect(s.roundsCompleted, 3);
    expect(s.recoveryScore, isNotNull);
  });

  test('end session returns Err for unknown id', () async {
    when(() => sessions.getById('nope')).thenAnswer((_) async => const Ok<Session?, AppException>(null));
    final uc = EndSession(sessions: sessions, streakProvider: () => 0);
    final result = await uc(
      sessionId: 'nope',
      endedAt: DateTime.now(),
      totalActualDuration: const Duration(minutes: 1),
      roundsCompleted: 0,
    );
    expect(result.isErr, isTrue);
  });
}
