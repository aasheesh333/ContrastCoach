import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/protocol_validator.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';

Result<Protocol, AppException> validateCustomProtocol(Protocol p) {
  final validation = validateProtocol(p);
  if (validation.isValid) return Ok(p);
  return Err(ValidationException('Custom protocol invalid', errors: validation.errors));
}
