import 'package:contrast_coach/domain/entities/phase_template.dart';

enum ProtocolCategory { recovery, energy, sleep, immunity, custom }
enum ProtocolDifficulty { beginner, intermediate, advanced }

class Protocol {
  const Protocol({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.rounds,
    required this.phases,
    this.cooldown = const [],
    this.isPro = false,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String description;
  final ProtocolCategory category;
  final ProtocolDifficulty difficulty;
  final int rounds;
  final List<PhaseTemplate> phases;
  final List<PhaseTemplate> cooldown;
  final bool isPro;
  final bool isCustom;

  Duration get totalDuration {
    final phaseSum = phases.fold<int>(0, (a, b) => a + b.duration.inSeconds);
    final cooldownSum = cooldown.fold<int>(0, (a, b) => a + b.duration.inSeconds);
    return Duration(seconds: phaseSum * rounds + cooldownSum);
  }
}
