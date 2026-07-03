import 'package:contrast_coach/presentation/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EditProfile renders fields + Save button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Save changes'), findsOneWidget);
  });
}
