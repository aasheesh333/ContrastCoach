import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/coach_reply_service.dart';
import 'package:contrast_coach/data/remote/coach/gemini_client.dart';
import 'package:contrast_coach/domain/entities/coach_message.dart';
import 'package:contrast_coach/domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl({
    GeminiClient? geminiClient,
    CoachReplyService fallbackService = const CoachReplyService(),
    this.offlineAlways = false,
  })  : _geminiClient = geminiClient ?? GeminiClient(),
        _fallback = fallbackService;

  final GeminiClient _geminiClient;
  final CoachReplyService _fallback;
  final bool offlineAlways;

  @override
  Future<Result<CoachMessage, AppException>> send(
    CoachMessage userMessage, {
    List<CoachMessage> history = const [],
  }) async {
    if (offlineAlways) {
      return Ok(_fallback.replyTo(userMessage));
    }
    final result = await _geminiClient.complete(
      userMessage.content,
      history: history,
    );
    return result.fold(
      (err) => Ok(_fallback.replyTo(userMessage)),
      (text) => text.isEmpty
          ? Ok(_fallback.replyTo(userMessage))
          : Ok(CoachMessage(
              id: 'coach_${userMessage.id}_${DateTime.now().millisecondsSinceEpoch}',
              role: CoachRole.coach,
              content: text,
              createdAt: DateTime.now(),
            )),
    );
  }
}
