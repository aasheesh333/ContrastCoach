import 'dart:async';

import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';

abstract class HealthRepository {
  Future<Result<bool, AppException>> isAvailable();
  Future<Result<bool, AppException>> requestPermissions();
  Future<Result<HealthSnapshot, AppException>> readSnapshot();
  Future<Result<void, AppException>> writeMindfulSession({
    required DateTime start,
    required DateTime end,
    required String title,
  });
  Stream<void> get permissionsRevokedStream;
}
