import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/coach_reply_service.dart';
import 'package:contrast_coach/data/repositories/coach_repository_impl.dart';
import 'package:contrast_coach/domain/entities/coach_message.dart';
import 'package:contrast_coach/domain/repositories/coach_repository.dart';
import 'package:contrast_coach/domain/usecases/send_coach_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CoachRepository repo;
  late SendCoachMessage usecase;

  setUp(() {
    repo = CoachRepositoryImpl(offlineAlways: true);
    usecase = SendCoachMessage(repo);
  });

  test('offline-gated SendCoachMessage returns a coach reply marked offline', () async {
    final userMessage = CoachMessage(
      id: 'u1',
      role: CoachRole.user,
      content: 'How do I start cold showers?',
      createdAt: DateTime(2026, 7, 3),
    );
    final result = await usecase(userMessage);
    expect(result.isOk, isTrue);
    final asOk = result as Ok;
    final reply = asOk.value as CoachMessage;
    expect(reply.role, CoachRole.coach);
    expect(reply.content, contains('[offline]'));
  });

  test('history param passes through (no throw)', () async {
    final userMessage = CoachMessage(
      id: 'u2',
      role: CoachRole.user,
      content: 'Advice?',
      createdAt: DateTime(2026, 7, 3),
    );
    final history = [
      CoachMessage(
        id: 'prev',
        role: CoachRole.coach,
        content: 'hi',
        createdAt: DateTime(2026, 7, 2),
      ),
    ];
    final result = await usecase(userMessage, history: history);
    expect(result.isOk, isTrue);
  });
}
