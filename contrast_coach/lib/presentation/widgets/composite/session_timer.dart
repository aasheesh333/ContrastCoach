import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

/// v4 session timer: 228px ring, 56px w200 timer, paired .cbtn controls.
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
  @override
  Widget build(BuildContext context) {
    final isCold = widget.phaseType == PhaseType.cold;
    final label = _phaseLabel();
    final timerText = _formatTime(widget.remaining);
    final fraction = _phaseFraction();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phase label
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xl * 2), // 32
        // 228px ring
        SizedBox(
          width: 228,
          height: 228,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: fraction,
              isCold: isCold,
            ),
            child: Center(
              child: Text(
                timerText,
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  color: AppColors.white,
                  letterSpacing: -2.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl * 2),
        // Paired .cbtn controls (warm/pause)
        _SessionControls(
          isCold: isCold,
          onPause: widget.onPause,
          onMic: widget.onMic,
        ),
        const SizedBox(height: AppSpacing.md),
        // Round info
        Text(
          'Round ${widget.currentRound} of ${widget.totalRounds}',
          style: TextStyle(
            fontFamily: AppTypography.bodyFont,
            color: AppColors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  String _phaseLabel() => switch (widget.phaseType) {
        PhaseType.sauna => 'SAUNA',
        PhaseType.cold => 'COLD PLUNGE',
        PhaseType.rest => 'REST',
        PhaseType.custom => 'CUSTOM',
      };

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double _phaseFraction() {
    final total = widget.plannedDuration.inSeconds;
    if (total == 0) return 0.0;
    final remaining = widget.remaining.inSeconds.clamp(0, total);
    return 1.0 - (remaining / total);
  }
}

/// Draws the 228px arc ring. Background track + animated sweep.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.isCold});

  final double fraction;
  final bool isCold;

  static const _stroke = 6.0;
  static const _radius = 114.0; // 228 / 2

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: _radius - _stroke / 2);

    // Background track
    final bgPaint = Paint()
      ..color = AppColors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, bgPaint);

    // Progress arc
    if (fraction > 0) {
      final progressPaint = Paint()
        ..shader = _gradientShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, fraction * 2 * pi, false, progressPaint);
    }
  }

  Shader _gradientShader(Rect rect) {
    return SweepGradient(
      colors: isCold
          ? [const Color(0xFF4DA8FF), const Color(0xFF0F4DA0)]
          : [const Color(0xFFFFB74D), const Color(0xFFD84315)],
      startAngle: 0,
      endAngle: 2 * pi,
    ).createShader(rect);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.fraction != fraction || old.isCold != isCold;
  }
}

/// v4 paired .cbtn controls: warm (primary) and pause (secondary) buttons.
class _SessionControls extends StatelessWidget {
  const _SessionControls({
    required this.isCold,
    this.onPause,
    this.onMic,
  });

  final bool isCold;
  final VoidCallback? onPause;
  final VoidCallback? onMic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause button (secondary)
        _CircleButton(
          icon: Icons.pause_rounded,
          onPressed: onPause,
          backgroundColor: AppColors.white.withOpacity(0.15),
        ),
        const SizedBox(width: AppSpacing.md),
        // Mic button (secondary)
        _CircleButton(
          icon: Icons.mic_none_rounded,
          onPressed: onMic,
          backgroundColor: AppColors.white.withOpacity(0.15),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.onPressed,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.white.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
