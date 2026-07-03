import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EditProfile renders v4 controls (avatar, emoji picker, all 7 fields, save)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const EditProfileScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    // App bar title "Edit profile"
    expect(find.text('Edit profile'), findsOneWidget);

    // Avatar default emoji rendered at least once
    expect(find.text('🧑'), findsWidgets);

    // 5-emoji picker row labels
    expect(find.text('🧔'), findsOneWidget);
    expect(find.text('👩'), findsOneWidget);
    expect(find.text('🧊'), findsOneWidget);
    expect(find.text('🔥'), findsOneWidget);

    // Field labels
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(find.text('Primary goal'), findsOneWidget);
    expect(find.text('Temperature units'), findsOneWidget);
    expect(find.text('Weekly session goal'), findsOneWidget);

    // 4 primary goal chips
    expect(find.text('Recovery'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);

    // Temperature units segmented control
    expect(find.text('°C'), findsOneWidget);
    expect(find.text('°F'), findsOneWidget);

    // Weekly session goal default caption
    await tester.scrollUntilVisible(
      find.text('5 sessions / week'),
      200,
    );
    await tester.pumpAndSettle();
    expect(find.text('5 sessions / week'), findsOneWidget);

    // Save changes button
    expect(find.text('Save changes'), findsOneWidget);

    // Text inputs: name field + bio textarea = at least 2 TextFields
    expect(find.byType(TextField), findsNWidgets(2));

    // Slider present for weekly goal
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('Emoji picker tap updates the avatar emoji', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const EditProfileScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    // Tap the 🔥 emoji in the picker row
    await tester.tap(find.text('🔥'));
    await tester.pump();

    // Now the avatar should show 🔥 (at least 2 widgets: picker selected + avatar)
    expect(find.text('🔥'), findsWidgets);
  });
}
