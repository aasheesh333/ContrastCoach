import 'package:contrast_coach/data/local/coach_reply_service.dart';
import 'package:contrast_coach/domain/entities/coach_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CoachReplyService();

  CoachMessage user(String content) => CoachMessage(
        id: 'u1',
        role: CoachRole.user,
        content: content,
        createdAt: DateTime(2026, 7, 3),
      );

  test('cold question triggers cold-exposure fallback text', () {
    final out = service.replyTo(user('How do I start cold showers?'));
    expect(out.role, CoachRole.coach);
    expect(out.content, contains('adrenaline'));
    expect(out.content, contains('[offline]'));
  });

  test('heat/sauna question triggers heat fallback', () {
    final out = service.replyTo(user('How long should I sauna?'));
    expect(out.content.toLowerCase(), contains('heat'));
    expect(out.content, contains('[offline]'));
  });

  test('recover question triggers recovery fallback', () {
    final out = service.replyTo(user('I am sore, what do I do to recover?'));
    expect(out.content, contains('contrast ratio 1:3'));
  });

  test('sleep question triggers sleep fallback', () {
    final out = service.replyTo(user('I can\'t sleep, am tired'));
    expect(out.content.toLowerCase(), contains('melatonin'));
  });

  test('unknown question triggers generic motivational fallback', () {
    final out = service.replyTo(user('Tell me anything'));
    expect(out.content.toLowerCase(), contains('consistent'));
  });

  test('reply id includes user message id for traceability', () {
    final out = service.replyTo(user('test'));
    expect(out.id, startsWith('coach_u1_'));
  });
}
