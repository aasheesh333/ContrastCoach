import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter/material.dart';

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

  String _goalEmoji(Goal g) => switch (g) {
        Goal.recovery => '🌙',
        Goal.energy => '⚡',
        Goal.sleep => '😴',
        Goal.immunity => '🛡️',
      };

  @override
  Widget build(BuildContext context) {
    final minutes = session.totalActualDuration.inMinutes;
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 320,
        height: 480,
        decoration: BoxDecoration(
          gradient: AppGradients.heroDark,
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ContrastCoach',
                  style: AppTypography.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.local_fire_department,
                    color: AppColors.heat, size: 22),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                recoveryScore == null
                    ? '--'
                    : recoveryScore!.toStringAsFixed(0),
                style: AppTypography.titleLarge?.copyWith(
                  fontSize: 96,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
            Center(
              child: Text(
                'RECOVERY SCORE',
                style: AppTypography.labelMediumV4?.copyWith(
                  color: AppColors.heat,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Spacer(),
            _Row(label: 'Goal', value: '${_goalEmoji(session.goal)} ${session.goal.name}'),
            const SizedBox(height: 8),
            _Row(label: 'Duration', value: '$minutes min'),
            const SizedBox(height: 8),
            _Row(
              label: 'Rounds',
              value: '${session.roundsCompleted}/${session.protocolRounds}',
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'Streak',
              value: '$streakDays day${streakDays == 1 ? '' : 's'} 🔥',
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodyLargeV4
                ?.copyWith(color: Colors.white70, fontSize: 13)),
        Text(value,
            style: AppTypography.bodyLargeV4
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
