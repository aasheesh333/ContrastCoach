import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders 3 items and fires onTap', (tester) async {
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
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
    await tester.tap(find.text('Streak'));
    expect(tapped, '/streak');
  });
}
