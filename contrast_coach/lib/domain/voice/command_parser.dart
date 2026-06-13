import 'package:contrast_coach/domain/entities/voice_command.dart';

VoiceCommand parseVoiceCommand(String transcript) {
  final t = transcript.toLowerCase().trim();

  if (_matchesAny(t, ['start', 'begin'])) {
    return _ok(VoiceCommandKind.start, transcript);
  }
  if (_matchesAny(t, ['next', 'skip'])) {
    return _ok(VoiceCommandKind.next, transcript);
  }
  if (_matchesAny(t, ['pause', 'wait'])) {
    return _ok(VoiceCommandKind.pause, transcript);
  }
  if (_matchesAny(t, ['resume', 'continue'])) {
    return _ok(VoiceCommandKind.resume, transcript);
  }
  if (_matchesAny(t, ['end', 'stop', 'finish', 'done'])) {
    return _ok(VoiceCommandKind.end, transcript);
  }
  if (_matchesAny(t, ['how long', 'time', 'how much'])) {
    return _ok(VoiceCommandKind.howLong, transcript);
  }
  if (_matchesAny(t, ['repeat', 'say again'])) {
    return _ok(VoiceCommandKind.repeat, transcript);
  }
  if (_matchesAny(t, ['log cold', 'felt cold'])) {
    return _ok(VoiceCommandKind.logCold, transcript);
  }
  if (_matchesAny(t, ['log hot', 'felt hot'])) {
    return _ok(VoiceCommandKind.logHot, transcript);
  }

  return const VoiceCommand(kind: VoiceCommandKind.unknown, confidence: 0.0, rawTranscript: '');
}

VoiceCommand _ok(VoiceCommandKind kind, String raw) =>
    VoiceCommand(kind: kind, confidence: 0.9, rawTranscript: raw);

bool _matchesAny(String t, List<String> patterns) => patterns.any(t.contains);
