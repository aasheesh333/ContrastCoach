import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';

Future<Result<void, AppException>> deleteAllUserData({
  required SessionRepository sessions,
  required Future<void> Function() deleteCloudAccount,
}) async {
  try {
    final allResult = await sessions.getAll();
    if (allResult is Err) {
      return Err((allResult as Err<dynamic, AppException>).error);
    }
    final list = (allResult as Ok<List<Session>, AppException>).value;
    for (final s in list) {
      await sessions.delete(s.id);
    }
    await deleteCloudAccount();
    return const Ok(null);
  } catch (e) {
    return Err(DatabaseException('Failed to delete user data', cause: e));
  }
}
