import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/account/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Account screen renders v4 chrome (title, Email, Change password, Google, Bio, Sign out, Delete)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const AccountScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Account & security'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.textContaining('Change password'), findsOneWidget);
    expect(find.textContaining('Google'), findsOneWidget);
    expect(find.textContaining('Biometric lock'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });
}
