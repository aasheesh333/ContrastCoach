import 'package:contrast_coach/presentation/screens/journal/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Journal renders header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: JournalScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Journal'), findsOneWidget);
  });
}
