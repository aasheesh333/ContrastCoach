import 'package:contrast_coach/presentation/screens/challenges/challenges_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Challenges renders header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChallengesScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Challenges'), findsOneWidget);
  });
}
