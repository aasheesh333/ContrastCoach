import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(_wrap(AppButton(label: 'Continue', onPressed: () {})));
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppButton(label: 'Go', onPressed: () => taps++)));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('does not invoke onPressed when null', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppButton(label: 'Disabled', onPressed: null)));
    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('tap target is at least 48dp', (tester) async {
    await tester.pumpWidget(_wrap(AppButton(label: 'Tap', onPressed: () {})));
    final size = tester.getSize(find.byType(AppButton));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('renders loading spinner when isLoading', (tester) async {
    await tester.pumpWidget(
      _wrap(AppButton(label: 'Save', onPressed: () {}, isLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('pill shape with full width', (tester) async {
    await tester.pumpWidget(
      _wrap(AppButton(label: 'Full', onPressed: () {}, fullWidth: true)),
    );
    final size = tester.getSize(find.byType(AppButton));
    expect(size.width, greaterThan(100));
  });
}
