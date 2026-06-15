import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';

abstract class ProtocolRepository {
  Future<Result<List<Protocol>, AppException>> getAll();
  Future<Result<Protocol?, AppException>> getById(String id);
}
