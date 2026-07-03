import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/screens/session/session_summary_screen.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    DatabaseProvider.setTestInstance(db);
  });

  tearDown(() async {
    await DatabaseProvider.dispose();
  });

  Session _makeSession() => Session(
        id: 'test-id',
        protocolId: 'test-protocol',
        goal: Goal.recovery,
        startedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        endedAt: DateTime.now(),
        totalPlannedDuration: const Duration(minutes: 45),
        totalActualDuration: const Duration(minutes: 45),
        roundsCompleted: 3,
        protocolRounds: 3,
        recoveryScore: 75.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phases: const [],
      );

  testWidgets('renders summary with mock session', (tester) async {
    await SessionRepositoryImpl(db).save(_makeSession());

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const SessionSummaryScreen(sessionId: 'test-id'),
      ),
    );

    // Wait for DB load + AnimatedSwitcher transition to complete
    await tester.pump(const Duration(milliseconds: 500));

    // Completion line
    expect(find.textContaining('Complete'), findsOneWidget);
    expect(find.textContaining('45:00'), findsOneWidget);
    expect(find.textContaining('3 rounds'), findsOneWidget);

    // Components
    expect(find.byType(RecoveryScoreCard), findsOneWidget);
    expect(find.textContaining('7-day HRV trend'), findsOneWidget);
    expect(find.textContaining('Best time'), findsOneWidget);
    expect(find.textContaining('Heat target hit this week'), findsOneWidget);
    expect(find.textContaining('New record'), findsOneWidget);

    // Mood journal card
    expect(find.text('📝 How did it feel?'), findsOneWidget);
    expect(find.text('😩 Tough'), findsOneWidget);
    expect(find.text('🙌 Great'), findsOneWidget);
    expect(find.text('😌 Calm'), findsOneWidget);

    // Action buttons
    expect(find.text('Save session'), findsOneWidget);
    expect(find.text('Share card 📤'), findsOneWidget);
    expect(find.text('Start another'), findsOneWidget);

    // Mood chip interactivity
    await tester.tap(find.widgetWithText(AppChip, '😩 Tough'));
    await tester.pump();
    final toughChip = tester.widget<AppChip>(find.widgetWithText(AppChip, '😩 Tough'));
    expect(toughChip.selected, isTrue);
  });
}
