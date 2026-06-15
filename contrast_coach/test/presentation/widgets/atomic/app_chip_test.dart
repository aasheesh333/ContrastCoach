import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(_wrap(const AppChip(label: 'Recovery')));
    expect(find.text('Recovery'), findsOneWidget);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppChip(label: 'X', onTap: () => taps++)));
    await tester.tap(find.byType(AppChip));
    expect(taps, 1);
  });
}
