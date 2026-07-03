import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Container(
            color: const Color(0xFF12121A),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      );

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(wrap(const AppPill(label: '3-day streak')));
    expect(find.text('3-day streak'), findsOneWidget);
  });

  testWidgets('uses 11/w600/white typography per v4 spec', (tester) async {
    await tester.pumpWidget(wrap(const AppPill(label: 'X')));
    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.fontSize, 11);
    expect(text.style?.fontWeight, FontWeight.w600);
    expect(text.style?.color, Colors.white);
  });

  testWidgets('corners are radius-11 per v4 spec', (tester) async {
    await tester.pumpWidget(wrap(const AppPill(label: 'X')));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppPill),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration as BoxDecoration;
    final r = decoration.borderRadius as BorderRadius;
    expect(r.topLeft, const Radius.circular(11));
    expect(r.bottomRight, const Radius.circular(11));
  });

  testWidgets('renders leading icon when provided', (tester) async {
    await tester.pumpWidget(wrap(const AppPill(
      label: 'fire',
      icon: Icons.local_fire_department,
    )));
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });
}
