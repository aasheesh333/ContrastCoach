import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter/material.dart';

/// v4 SHARE CARD painter. Mockup `.share`:
///   - bg linear-gradient(150deg,#12121a,#3a1e12), radius 24,
///   - padding 26 22 (vertical 26, horizontal 22), elev shadow,
///   - text-align center, color #fff.
///   Inner content (top → bottom):
///     - "CONTRASTCOACH" 12 w700 ls2 opacity .7
///     - .n big number = 60 w800 heat→cold2 gradient text-clip
///     - "Recovery · STRONG 🔥" 700 (string-flavored based on band)
///     - "26:40 · 3 rounds · 7-day streak"  .8 opacity 13px margin-top 8
///     - "🌡️❄️🌡️❄️" 22px row margin-top 16
class ShareCardPainter extends StatelessWidget {
  const ShareCardPainter({
    super.key,
    required this.session,
    required this.recoveryScore,
    this.streakDays = 0,
    this.boundaryKey,
  });

  final Session session;
  final double? recoveryScore;
  final int streakDays;
  final GlobalKey? boundaryKey;

  @override
  Widget build(BuildContext context) {
    final minutes = session.totalActualDuration.inMinutes;
    final secondsRem = session.totalActualDuration.inSeconds % 60;
    final time = '${minutes.toString().padLeft(2, '0')}:${secondsRem.toString().padLeft(2, '0')}';
    final rounds = session.roundsCompleted;
    final scoreValue = recoveryScore == null ? null : recoveryScore!.round();
    final bandLabel = _bandLabelFromScore(scoreValue);
    final emojiRow = _emojiRowFromPhases(session);

    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
        decoration: BoxDecoration(
          gradient: AppGradients.shareCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x47141428),
              blurRadius: 24,
              offset: Offset(0, 8),
              spreadRadius: -16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'CONTRASTCOACH',
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xB3FFFFFF),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.scoreTextShare.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                scoreValue == null ? '—' : '$scoreValue',
                style: const TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recovery · $bandLabel 🔥',
              style: const TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$time · $rounds rounds · $streakDays-day streak',
              style: const TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 13,
                color: Color(0xCCFFFFFF),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emojiRow,
              style: const TextStyle(fontSize: 22, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  String _bandLabelFromScore(int? score) {
    if (score == null) return 'Recovery';
    if (score <= 40) return 'Rest';
    if (score <= 70) return 'Solid';
    return 'Strong';
  }

  /// Replicates the mockup "🌡️❄️🌡️❄️" alternation based on actual phase order.
  String _emojiRowFromPhases(Session s) {
    final phases = s.phases.map((p) {
      switch (p.type) {
        case PhaseType.cold:
          return '❄️';
        case PhaseType.sauna:
        case PhaseType.rest:
        case PhaseType.custom:
          return '🌡️';
      }
    }).toList();
    if (phases.length >= 4) {
      return phases.take(4).join();
    }
    if (phases.isNotEmpty) {
      // Pad up to 4 with alternation.
      return List.generate(4, (i) => phases[i % phases.length]).join();
    }
    return '🌡️❄️🌡️❄️';
  }
}
