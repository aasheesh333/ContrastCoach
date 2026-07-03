import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final segments = const [
    AppSegment(value: 'week', label: 'Week'),
    AppSegment(value: 'month', label: 'Month'),
    AppSegment(value: 'year', label: 'Year'),
  ];

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('renders all segment labels', (tester) async {
    await tester.pumpWidget(wrap(AppSegmentedControl<String>(
      segments: segments,
      value: 'week',
      onChanged: (_) {},
    )));
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
  });

  testWidgets('fires onChanged with the selected value', (tester) async {
    String? selected;
    await tester.pumpWidget(wrap(AppSegmentedControl<String>(
      segments: segments,
      value: 'week',
      onChanged: (v) => selected = v,
    )));
    await tester.tap(find.text('Month'));
    await tester.pump();
    expect(selected, 'month');
  });

  testWidgets('selected segment uses card bg + ink text', (tester) async {
    await tester.pumpWidget(wrap(AppSegmentedControl<String>(
      segments: segments,
      value: 'week',
      onChanged: (_) {},
    )));
    final weekContainerFinder = find.ancestor(
      of: find.text('Week'),
      matching: find.byType(AnimatedContainer),
    );
    final weekContainer = tester.widget<AnimatedContainer>(weekContainerFinder);
    final decoration = weekContainer.decoration as BoxDecoration;
    expect(decoration.color, isNot(Colors.transparent));
  });

  testWidgets('does not crash with null onChanged', (tester) async {
    await tester.pumpWidget(wrap(AppSegmentedControl<String>(
      segments: segments,
      value: 'week',
      onChanged: null,
    )));
    expect(find.text('Week'), findsOneWidget);
  });
}
