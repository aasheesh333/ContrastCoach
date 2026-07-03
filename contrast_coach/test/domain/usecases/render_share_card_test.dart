import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/render_share_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/share_card_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Session _make({
  Goal goal = Goal.recovery,
  int minutes = 15,
  int rounds = 3,
  int planned = 3,
  double? score,
  DateTime? startedAt,
}) {
  final now = startedAt ?? DateTime(2026, 7, 3);
  return Session(
    id: 's1',
    protocolId: 'recovery_standard',
    goal: goal,
    startedAt: now,
    totalPlannedDuration: Duration(minutes: minutes),
    totalActualDuration: Duration(minutes: minutes),
    roundsCompleted: rounds,
    protocolRounds: planned,
    recoveryScore: score,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('composeShareCardContent', () {
    test('renders full DTO with score', () {
      final s = _make(score: 88);
      final dto = composeShareCardContent(s, recoveryScore: 88, streakDays: 7);
      expect(dto.title, '88 / 100');
      expect(dto.subtitle, 'recovery');
      expect(dto.minutes, 15);
      expect(dto.roundsDone, 3);
      expect(dto.roundsPlanned, 3);
      expect(dto.goalEmoji, '🌙');
      expect(dto.goalLabel, 'recovery');
      expect(dto.streakDays, 7);
    });

    test('renders fallback title when score null', () {
      final s = _make(score: null);
      final dto = composeShareCardContent(s);
      expect(dto.title, "Today's contrast session");
    });

    test('emits correct emoji for each goal', () {
      for (final g in Goal.values) {
        final dto = composeShareCardContent(_make(goal: g));
        expect(dto.goalEmoji, isNotEmpty);
        expect(dto.goalLabel, g.name);
      }
    });
  });

  group('ShareCardPainter widget smoke', () {
    testWidgets('shows recovery score when provided', (tester) async {
      final s = _make(score: 88);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShareCardPainter(
                session: s,
                recoveryScore: 88,
                streakDays: 5,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('RECOVERY SCORE'), findsOneWidget);
      expect(find.text('88'), findsOneWidget);
    });

    testWidgets('renders -- when score null', (tester) async {
      final s = _make(score: null);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShareCardPainter(session: s, recoveryScore: null),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('--'), findsOneWidget);
    });
  });
}
