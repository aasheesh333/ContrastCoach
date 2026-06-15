import 'package:contrast_coach/domain/entities/voice_command.dart';
import 'package:contrast_coach/domain/voice/command_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseVoiceCommand', () {
    test('detects start', () {
      expect(parseVoiceCommand('start').kind, VoiceCommandKind.start);
      expect(parseVoiceCommand('Begin').kind, VoiceCommandKind.start);
    });

    test('detects next and skip', () {
      expect(parseVoiceCommand('next phase').kind, VoiceCommandKind.next);
      expect(parseVoiceCommand('skip this').kind, VoiceCommandKind.next);
    });

    test('detects pause', () {
      expect(parseVoiceCommand('pause').kind, VoiceCommandKind.pause);
      expect(parseVoiceCommand('wait').kind, VoiceCommandKind.pause);
    });

    test('detects resume', () {
      expect(parseVoiceCommand('resume').kind, VoiceCommandKind.resume);
      expect(parseVoiceCommand('continue').kind, VoiceCommandKind.resume);
    });

    test('detects end', () {
      expect(parseVoiceCommand('end').kind, VoiceCommandKind.end);
      expect(parseVoiceCommand('stop').kind, VoiceCommandKind.end);
      expect(parseVoiceCommand('finish').kind, VoiceCommandKind.end);
    });

    test('detects how long', () {
      expect(parseVoiceCommand('how long').kind, VoiceCommandKind.howLong);
      expect(parseVoiceCommand('time left').kind, VoiceCommandKind.howLong);
    });

    test('detects repeat', () {
      expect(parseVoiceCommand('repeat').kind, VoiceCommandKind.repeat);
    });

    test('detects log cold', () {
      expect(parseVoiceCommand('log cold').kind, VoiceCommandKind.logCold);
    });

    test('detects log hot', () {
      expect(parseVoiceCommand('log hot').kind, VoiceCommandKind.logHot);
    });

    test('returns unknown for gibberish', () {
      expect(parseVoiceCommand('the quick brown fox').kind, VoiceCommandKind.unknown);
    });

    test('case-insensitive', () {
      expect(parseVoiceCommand('PAUSE').kind, VoiceCommandKind.pause);
      expect(parseVoiceCommand('NeXt').kind, VoiceCommandKind.next);
    });

    test('confidence is 0 for unknown', () {
      expect(parseVoiceCommand('xyz').confidence, 0.0);
    });

    test('confidence is high for known', () {
      expect(parseVoiceCommand('start').confidence, greaterThan(0.5));
    });
  });
}
