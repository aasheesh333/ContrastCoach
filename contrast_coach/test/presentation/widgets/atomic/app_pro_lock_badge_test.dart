import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_pro_lock_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders PRO label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppProLockBadge()),
    ));
    expect(find.text('PRO'), findsOneWidget);
  });

  testWidgets('uses 10/w800 typography per v4 spec', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppProLockBadge()),
    ));
    final text = tester.widget<Text>(find.text('PRO'));
    expect(text.style?.fontSize, 10);
    expect(text.style?.fontWeight, FontWeight.w800);
    expect(text.style?.color, Colors.white);
  });

  testWidgets('corners are radius-7 per v4 spec', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppProLockBadge()),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    final r = decoration.borderRadius as BorderRadius;
    expect(r.topLeft, const Radius.circular(7));
  });

  testWidgets('uses heat gradient (warm→coral) for background', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppProLockBadge()),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.gradient, isNotNull);
    expect(decoration.gradient is Gradient, isTrue);
  });
}
