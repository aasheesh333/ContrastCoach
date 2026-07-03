import 'package:contrast_coach/presentation/screens/explore/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Explore renders hero header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Explore'), findsOneWidget);
  });
}
