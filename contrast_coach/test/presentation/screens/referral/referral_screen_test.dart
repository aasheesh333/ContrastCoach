import 'package:contrast_coach/presentation/screens/referral/referral_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Referral renders hero header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReferralScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Invite friends, earn Pro'), findsOneWidget);
  });
}
