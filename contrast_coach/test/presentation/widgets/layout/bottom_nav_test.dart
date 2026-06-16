import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders 4 items and fires onTap', (tester) async {
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
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.text('Streak'));
    expect(tapped, '/streak');
  });
}
