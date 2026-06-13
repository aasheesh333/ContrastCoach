import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    const stubScore = _StubScore();
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Session complete', showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RecoveryScoreCard(score: stubScore.toDomain()),
              const SizedBox(height: 32),
              AppButton(
                label: 'Save',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Discard',
                onPressed: () => context.go('/home'),
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StubScore {
  const _StubScore();
  domain.RecoveryScore toDomain() => const domain.RecoveryScore(
        value: 78,
        band: ScoreBand.strong,
        insight: 'Strong session. Adherence: Completed 95% of planned duration.',
        factors: [],
      );
}
