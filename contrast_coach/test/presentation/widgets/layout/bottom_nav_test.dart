import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders 5 items and fires onTap', (tester) async {
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: ContrastBottomNav(
          currentLocation: '/home',
          onTap: (loc) => tapped = loc,
        ),
      ),
    ));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Streak'), findsNothing);
    expect(find.text('Profile'), findsNothing);
    await tester.tap(find.text('Explore'));
    expect(tapped, '/explore');
    await tester.tap(find.text('Coach'));
    expect(tapped, '/coach');
    await tester.tap(find.text('You'));
    expect(tapped, '/settings');
  });
}
