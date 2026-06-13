import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/session.dart';

abstract class SessionRepository {
  Future<Result<Session, AppException>> save(Session session);
  Future<Result<Session?, AppException>> getById(String id);
  Future<Result<List<Session>, AppException>> getAll({int? limit, DateTime? since});
  Future<Result<void, AppException>> delete(String id);
  Stream<List<Session>> watchAll();
  Future<int> getStreakDays();
}
