import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/coach_message.dart';

abstract class CoachRepository {
  Future<Result<CoachMessage, AppException>> send(
    CoachMessage userMessage, {
    List<CoachMessage> history = const [],
  });
}
