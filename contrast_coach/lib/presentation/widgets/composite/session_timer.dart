import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:flutter/material.dart';

class SessionTimer extends StatefulWidget {
  const SessionTimer({
    super.key,
    required this.phaseType,
    required this.remaining,
    required this.plannedDuration,
    required this.currentRound,
    required this.totalRounds,
    required this.targetTempC,
    this.onPause,
    this.onMic,
  });

  final PhaseType phaseType;
  final Duration remaining;
  final Duration plannedDuration;
  final int currentRound;
  final int totalRounds;
  final double? targetTempC;
  final VoidCallback? onPause;
  final VoidCallback? onMic;

  @override
  State<SessionTimer> createState() => _SessionTimerState();
}

class _SessionTimerState extends State<SessionTimer> {
  double _phaseFraction = 0.0;
  double _overallFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _phaseFraction = _computePhaseFraction();
    _overallFraction = _computeOverallFraction();
  }

  @override
  void didUpdateWidget(covariant SessionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remaining != oldWidget.remaining ||
        widget.plannedDuration != oldWidget.plannedDuration ||
        widget.currentRound != oldWidget.currentRound ||
        widget.totalRounds != oldWidget.totalRounds) {
      setState(() {
        _phaseFraction = _computePhaseFraction();
        _overallFraction = _computeOverallFraction();
      });
    }
  }

  double _computePhaseFraction() {
    if (widget.plannedDuration.inSeconds == 0) return 0.0;
    return (1.0 - widget.remaining.inSeconds / widget.plannedDuration.inSeconds)
        .clamp(0.0, 1.0);
  }

  double _computeOverallFraction() {
    if (widget.totalRounds == 0) return 0.0;
    return ((widget.currentRound - 1) + _computePhaseFraction()) / widget.totalRounds;
  }

  String get _phaseLabel => switch (widget.phaseType) {
        PhaseType.sauna => 'SAUNA',
        PhaseType.cold => 'COLD PLUNGE',
        PhaseType.rest => 'REST',
        PhaseType.custom => 'CUSTOM',
      };

  Color get _phaseTint => switch (widget.phaseType) {
        PhaseType.sauna => AppColors.brandWarm,
        PhaseType.cold => AppColors.brandCool,
        PhaseType.rest => AppColors.lightGray,
        PhaseType.custom => AppColors.brandCoral,
      };

  @override
  Widget build(BuildContext context) {
    final m = widget.remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = widget.remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _phaseTint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _phaseLabel,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        if (widget.targetTempC != null) ...[
          const SizedBox(height: 8),
          Text(
            'Target ${widget.targetTempC!.round()}°C',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppColors.white.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          '$m:$s',
          style: AppTypography.timerHero.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 24),
        TweenAnimationBuilder<double>(
          tween: Tween(end: _phaseFraction),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, animatedPhase, child) {
            return SizedBox(
              width: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 4,
                  color: AppColors.white.withOpacity(0.20),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedPhase.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_phaseTint, AppColors.white],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Round ${widget.currentRound} of ${widget.totalRounds}',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.white.withOpacity(0.75),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppColors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: _overallFraction),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedOverall, _) {
                      return Text(
                        '${(animatedOverall * 100).round()}%',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(end: _overallFraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, animatedOverall, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 3,
                      color: AppColors.white.withOpacity(0.18),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: animatedOverall.clamp(0.0, 1.0),
                        child: Container(color: AppColors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundIconButton(
              icon: Icons.pause_rounded,
              onPressed: widget.onPause,
            ),
            const SizedBox(width: 24),
            _RoundIconButton(
              icon: Icons.mic_none_rounded,
              onPressed: widget.onMic,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Say "next phase" or tap pause',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.white.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
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
      color: AppColors.white.withOpacity(0.16),
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
    final fg = active ? AppColors.charcoal : AppColors.white.withOpacity(0.75);
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

class ActiveSessionBackground extends StatelessWidget {
  const ActiveSessionBackground({super.key, required this.child, required this.phaseType});
  final Widget child;
  final PhaseType phaseType;

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForPhase(phaseType);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }

  LinearGradient _gradientForPhase(PhaseType type) {
    return switch (type) {
      PhaseType.sauna => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.brandWarm, AppColors.brandCoral],
      ),
      PhaseType.cold => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D7CF1), Color(0xFF64B5F6)],
      ),
      PhaseType.rest => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.midGray, AppColors.warmBeige],
      ),
      PhaseType.custom => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.brandWarm, Color(0xFF2D7CF1)],
      ),
    };
  }
}
