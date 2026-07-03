import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/referral/referral_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Referral renders v4 chrome (Invite friends, give month, share)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const ReferralScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Invite friends'), findsOneWidget);
    expect(find.text('Give a month, get a month'), findsOneWidget);
    expect(find.textContaining('Share invite link'), findsOneWidget);
  });
}
