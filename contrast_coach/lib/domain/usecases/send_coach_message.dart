import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/coach_message.dart';
import 'package:contrast_coach/domain/repositories/coach_repository.dart';

class SendCoachMessage {
  const SendCoachMessage(this._repo);
  final CoachRepository _repo;

  Future<Result<CoachMessage, AppException>> call(
    CoachMessage userMessage, {
    List<CoachMessage> history = const [],
  }) async {
    return _repo.send(userMessage, history: history);
  }
}
