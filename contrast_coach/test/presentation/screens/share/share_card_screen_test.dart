import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/screens/share/share_card_screen.dart';
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
        id: 'share-test-id',
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

  testWidgets('renders share card with session info', (tester) async {
    await SessionRepositoryImpl(db).save(_makeSession());

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const ShareCardScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Share card'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });
}
