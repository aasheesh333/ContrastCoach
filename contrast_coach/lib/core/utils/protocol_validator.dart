import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';

class ProtocolValidationResult {
  const ProtocolValidationResult({required this.isValid, required this.errors});
  final bool isValid;
  final List<String> errors;
}

ProtocolValidationResult validateProtocol(Protocol p) {
  final errors = <String>[];

  if (p.phases.isEmpty) {
    errors.add('Protocol must have at least one phase.');
  }
  if (p.rounds < 1) {
    errors.add('Protocol must have at least one round.');
  }
  if (p.rounds > 5) {
    errors.add('Cannot exceed 5 rounds per session (safety limit).');
  }

  for (final phase in p.phases) {
    if (phase.type == PhaseType.sauna && phase.duration.inMinutes > 30) {
      errors.add('Sauna phase exceeds 30 minutes (safety limit).');
    }
    if (phase.type == PhaseType.cold) {
      if (phase.targetTempC != null && phase.targetTempC! < 5) {
        errors.add('Cold temperature below 5C (safety limit).');
      }
      if (phase.targetTempC != null && phase.targetTempC! > 20) {
        errors.add("Cold temperature above 20C - that's a cool shower, not a plunge.");
      }
    }
  }

  final totalSec = p.totalDuration.inSeconds;
  if (totalSec > 60 * 60) {
    errors.add('Total duration exceeds 60 minutes (safety limit).');
  }

  return ProtocolValidationResult(isValid: errors.isEmpty, errors: errors);
}
