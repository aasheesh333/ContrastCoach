import 'package:contrast_coach/domain/entities/coach_message.dart';

const String _kFallbackSignature = '[offline]';

class CoachReplyService {
  const CoachReplyService();

  CoachMessage replyTo(CoachMessage userMessage) {
    final text = userMessage.content.toLowerCase();
    final body = _pickFallback(text);
    return CoachMessage(
      id: 'coach_${userMessage.id}_${userMessage.createdAt.millisecondsSinceEpoch}',
      role: CoachRole.coach,
      content: '$body\n\n$_kFallbackSignature',
      createdAt: DateTime.now(),
    );
  }

  String _pickFallback(String lower) {
    if (lower.contains('cold') || lower.contains('shower')) {
      return 'Cold exposure spikes adrenaline 200%+ and boosts noradrenaline for hours. For beginners: start with 30s, build to 2-3 minutes. Stop if you feel dizzy.';
    }
    if (lower.contains('heat') || lower.contains('sauna')) {
      return 'Heat exposure dilates blood vessels and stresses the cardiovascular system gently. 15-20 min at 80C is a typical starting range; hydrate before and after.';
    }
    if (lower.contains('recover') || lower.contains('sore')) {
      return 'For recovery: contrast ratio 1:3 (cold:hot) for 3-4 rounds, finish cold if it\'s morning or hot if at night. Sleep is recovery cheat-code.';
    }
    if (lower.contains('sleep') || lower.contains('tired')) {
      return 'Hot sauna 15 min before bed raises core temp; the drop afterwards cues melatonin. Avoid blue light for 90 min after.';
    }
    return 'Great question. Staying consistent matters more than the perfect protocol. Aim for 3-4 sessions per week of any contrast routine. You\'re doing the work.';
  }
}
