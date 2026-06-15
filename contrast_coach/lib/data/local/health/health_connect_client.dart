import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';
import 'package:contrast_coach/domain/repositories/health_repository.dart';
import 'package:health/health.dart';

/// Health Connect client implementing [HealthRepository].
///
/// Reads HR, HRV, sleep, RHR, steps, workouts. Writes MindfulSession.
/// All processing happens on-device; only computed metrics are persisted.
class HealthConnectClient implements HealthRepository {
  HealthConnectClient({Health? health}) : _health = health ?? Health();
  final Health _health;

  static const _readTypes = <HealthDataType>[
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.STEPS,
    HealthDataType.WORKOUT,
  ];

  @override
  Future<Result<bool, AppException>> isAvailable() async {
    try {
      final available = await _health.isHealthConnectAvailable();
      return Ok(available);
    } catch (e) {
      return Err(HealthPermissionException('Health Connect availability check failed', cause: e));
    }
  }

  @override
  Future<Result<bool, AppException>> requestPermissions() async {
    try {
      final permissions = List<HealthDataAccess>.filled(
        _readTypes.length,
        HealthDataAccess.READ,
      );
      final granted = await _health.requestAuthorization(
        _readTypes,
        permissions: permissions,
      );
      return Ok(granted);
    } catch (e) {
      return Err(HealthPermissionException('Permission request failed', cause: e));
    }
  }

  @override
  Future<Result<HealthSnapshot, AppException>> readSnapshot() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final yesterday = now.subtract(const Duration(days: 1));

      final hrvData = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
        startTime: weekAgo,
        endTime: now,
      );
      final sleepData = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.SLEEP_ASLEEP],
        startTime: yesterday,
        endTime: now,
      );

      final hrvValues = hrvData
          .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
          .toList();
      final hrvAvg = hrvValues.isEmpty
          ? null
          : hrvValues.reduce((a, b) => a + b) / hrvValues.length;
      final hrvTrend = hrvValues.length < 4
          ? null
          : (hrvValues.skip(hrvValues.length ~/ 2).reduce((a, b) => a + b) /
                  (hrvValues.length - hrvValues.length ~/ 2)) -
              (hrvValues.take(hrvValues.length ~/ 2).reduce((a, b) => a + b) /
                  (hrvValues.length ~/ 2));

      final lastNightSleep = sleepData.isEmpty
          ? null
          : sleepData
              .map((p) => p.dateTo.difference(p.dateFrom).inMinutes)
              .reduce((a, b) => a + b);

      return Ok(HealthSnapshot(
        capturedAt: now,
        lastNightSleepMinutes: lastNightSleep,
        hrvRmssd7DayAvg: hrvAvg,
        hrvRmssdTrend7Day: hrvTrend,
      ));
    } catch (e) {
      return Err(HealthReadException('Failed to read health data', cause: e));
    }
  }

  @override
  Future<Result<void, AppException>> writeMindfulSession({
    required DateTime start,
    required DateTime end,
    required String title,
  }) async {
    try {
      final success = await _health.writeHealthData(
        value: end.difference(start).inMinutes.toDouble(),
        type: HealthDataType.MINDFULNESS,
        startTime: start,
        endTime: end,
      );
      return success ? const Ok(null) : const Err(HealthReadException('Write failed'));
    } catch (e) {
      return Err(HealthReadException('Write failed', cause: e));
    }
  }
}
