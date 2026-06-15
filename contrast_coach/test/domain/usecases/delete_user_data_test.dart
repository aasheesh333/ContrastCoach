import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/delete_user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepo extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepo sessions;

  setUp(() {
    sessions = _MockSessionRepo();
  });

  test('delete all user data clears local + cloud', () async {
    final s1 = Session(
      id: 's1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: DateTime(2026, 6, 1),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    );
    when(() => sessions.getAll()).thenAnswer(
      (_) async => Ok<List<Session>, AppException>([s1]),
    );
    when(() => sessions.delete(any())).thenAnswer(
      (_) async => const Ok(null),
    );

    var cloudCalled = false;
    final result = await deleteAllUserData(
      sessions: sessions,
      deleteCloudAccount: () async {
        cloudCalled = true;
      },
    );

    expect(result.isOk, isTrue);
    verify(() => sessions.delete('s1')).called(1);
    expect(cloudCalled, isTrue);
  });
}
