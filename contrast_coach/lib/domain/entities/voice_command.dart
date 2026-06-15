enum VoiceCommandKind {
  start, next, pause, resume, end, howLong, repeat, logCold, logHot, unknown,
}

class VoiceCommand {
  const VoiceCommand({
    required this.kind,
    required this.confidence,
    required this.rawTranscript,
  });
  final VoiceCommandKind kind;
  final double confidence;
  final String rawTranscript;
}
