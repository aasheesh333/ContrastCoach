import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:flutter/material.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';

class SessionTimer extends StatelessWidget {
  const SessionTimer({
    super.key,
    required this.phaseType,
    required this.remaining,
    required this.currentRound,
    required this.totalRounds,
    this.onPause,
    this.onMic,
  });

  final PhaseType phaseType;
  final Duration remaining;
  final int currentRound;
  final int totalRounds;
  final VoidCallback? onPause;
  final VoidCallback? onMic;

  String get _phaseLabel => switch (phaseType) {
        PhaseType.sauna => 'SAUNA',
        PhaseType.cold => 'COLD PLUNGE',
        PhaseType.rest => 'REST',
        PhaseType.custom => 'CUSTOM',
      };

  @override
  Widget build(BuildContext context) {
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _phaseLabel,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '$m:$s',
          style: AppTypography.timerHero.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 4,
              color: AppColors.white.withOpacity(0.25),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: totalRounds == 0 ? 0 : currentRound / totalRounds,
                child: Container(color: AppColors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Round $currentRound of $totalRounds',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundIconButton(
              icon: Icons.pause,
              onPressed: onPause,
            ),
            const SizedBox(width: 24),
            _RoundIconButton(
              icon: Icons.mic,
              onPressed: onMic,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Say "next phase" or tap',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withOpacity(0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.white, size: 28),
        ),
      ),
    );
  }
}

/// Phase pill chip (SAUNA / COLD / REST). Active variant uses cool/warm tint.
class PhasePill extends StatelessWidget {
  const PhasePill({super.key, required this.type, this.active = false});
  final PhaseType type;
  final bool active;

  Color get _tint => switch (type) {
        PhaseType.sauna => AppColors.brandWarm,
        PhaseType.cold => AppColors.brandCool,
        PhaseType.rest => AppColors.midGray,
        PhaseType.custom => AppColors.brandCoral,
      };

  String get _label => switch (type) {
        PhaseType.sauna => 'SAUNA',
        PhaseType.cold => 'COLD',
        PhaseType.rest => 'REST',
        PhaseType.custom => 'CUSTOM',
      };

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.white : Colors.transparent;
    final fg = active ? AppColors.charcoal : AppColors.white.withOpacity(0.7);
    final border = active ? AppColors.white : AppColors.white.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: active ? _tint : Colors.transparent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen gradient background for active session.
class ActiveSessionBackground extends StatelessWidget {
  const ActiveSessionBackground({super.key, required this.child, required this.phaseType});
  final Widget child;
  final PhaseType phaseType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.contrast),
      child: child,
    );
  }
}
