import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('toggles value', (tester) async {
    bool value = false;
    await tester.pumpWidget(_wrap(
      AppSwitch(value: value, onChanged: (v) => value = v),
    ));
    await tester.tap(find.byType(AppSwitch));
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('does not crash with,null onChanged', (tester) async {
    await tester.pumpWidget(_wrap(const AppSwitch(value: false, onChanged: null)));
    expect(find.byType(AppSwitch), findsOneWidget);
  });

  testWidgets('renders 46x28 rail', (tester) async {
    await tester.pumpWidget(_wrap(AppSwitch(
      value: false,
      onChanged: (_) {},
    )));
    final size = tester.getSize(find.byType(AppSwitch));
    expect(size.width, 46);
    expect(size.height, 28);
  });
}
