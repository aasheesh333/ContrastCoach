import 'package:contrast_coach/domain/entities/recovery_score.dart';
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders correct score text and label', (tester) async {
    const score = RecoveryScore(
      value: 75.0,
      band: ScoreBand.strong,
      insight: 'test',
      factors: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecoveryScoreCard(score: score),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('75'), findsOneWidget);
    expect(find.text('STRONG RECOVERY'), findsOneWidget);
  });

  testWidgets('renders moderate recovery label', (tester) async {
    const score = RecoveryScore(
      value: 55.0,
      band: ScoreBand.moderate,
      insight: 'test',
      factors: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecoveryScoreCard(score: score),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('55'), findsOneWidget);
    expect(find.text('MODERATE RECOVERY'), findsOneWidget);
  });

  testWidgets('renders low recovery label', (tester) async {
    const score = RecoveryScore(
      value: 25.0,
      band: ScoreBand.low,
      insight: 'test',
      factors: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecoveryScoreCard(score: score),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('25'), findsOneWidget);
    expect(find.text('LOW RECOVERY'), findsOneWidget);
  });
}
