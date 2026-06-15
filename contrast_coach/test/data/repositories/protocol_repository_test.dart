import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _protocolsJson = '''
{
  "version": 1,
  "protocols": [
    {
      "id": "recovery_standard",
      "name": "Standard Recovery",
      "description": "Balanced contrast",
      "category": "recovery",
      "difficulty": "intermediate",
      "rounds": 3,
      "phases": [
        {"type": "sauna", "duration": 900, "targetTempC": 80},
        {"type": "cold", "duration": 120, "targetTempC": 12}
      ]
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = const StringCodec().decodeMessage(message);
      if (key == 'assets/protocols.json') {
        return const StringCodec().encodeMessage(_protocolsJson);
      }
      return null;
    });
  });

  test('loads protocols from assets', () async {
    final ProtocolRepository repo = ProtocolRepositoryImpl();
    final result = await repo.getAll();
    expect(result.isOk, isTrue);
    final ok = result as dynamic;
    final protocols = ok.value as List<Protocol>;
    expect(protocols, hasLength(1));
    expect(protocols.first.id, 'recovery_standard');
    expect(protocols.first.phases.first.type, PhaseType.sauna);
  });

  test('getById returns null for unknown id', () async {
    final ProtocolRepository repo = ProtocolRepositoryImpl();
    final result = await repo.getById('nope');
    expect(result.isOk, isTrue);
    expect((result as dynamic).value, isNull);
  });
}
