import 'package:contrast_coach/core/utils/protocol_validator.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:flutter_test/flutter_test.dart';

Protocol _validProtocol() => Protocol(
      id: 'p1',
      name: 'Test',
      description: 'Test',
      category: ProtocolCategory.recovery,
      difficulty: ProtocolDifficulty.beginner,
      rounds: 3,
      phases: const [
        PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 15)),
        PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2)),
      ],
    );

void main() {
  group('validateProtocol', () {
    test('valid protocol passes', () {
      final result = validateProtocol(_validProtocol());
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('rejects total duration > 60 min', () {
      final p = Protocol(
        id: 'p1', name: 'Long', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 5,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 20))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('60 minutes')), isTrue);
    });

    test('rejects sauna > 30 min per phase', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 31))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('30 minutes')), isTrue);
    });

    test('rejects cold < 5C', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1,
        phases: const [PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2), targetTempC: 3)],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('5C')), isTrue);
    });

    test('rejects cold > 20C', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1,
        phases: const [PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2), targetTempC: 25)],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('plunge')), isTrue);
    });

    test('rejects > 5 rounds', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 6,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 5))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('5 rounds')), isTrue);
    });

    test('rejects 0 rounds', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 0,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 5))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
    });

    test('rejects empty phases', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1, phases: const [],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
    });
  });
}
