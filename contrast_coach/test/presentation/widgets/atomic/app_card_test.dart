import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(_wrap(const AppCard(child: Text('Card'))));
    expect(find.text('Card'), findsOneWidget);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppCard(child: const Text('X'), onTap: () => taps++)));
    await tester.tap(find.byType(AppCard));
    await tester.pump();
    expect(taps, 1);
  });
}
