import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/presentation/widgets/composite/progress_bar.dart';
import 'package:flutter/material.dart';

class SessionTimer extends StatelessWidget {
  const SessionTimer({
    super.key,
    required this.phaseLabel,
    required this.remaining,
    required this.currentRound,
    required this.totalRounds,
  });

  final String phaseLabel;
  final Duration remaining;
  final int currentRound;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          phaseLabel.toUpperCase(),
          style: tt.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$m:$s',
          style: AppTypography.timerMono.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 32),
        SessionProgressBar(current: currentRound, total: totalRounds),
      ],
    );
  }
}
