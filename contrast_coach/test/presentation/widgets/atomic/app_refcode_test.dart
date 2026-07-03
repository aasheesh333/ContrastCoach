import 'dart:ui';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_refcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the code text', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppRefCode(code: 'AASHEESH50')),
    ));
    expect(find.text('AASHEESH50'), findsOneWidget);
  });

  testWidgets('uses 26/w500/heat typography per v4 spec', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppRefCode(code: 'X')),
    ));
    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.fontSize, 26);
    expect(text.style?.fontWeight, FontWeight.w500);
    expect(text.style?.fontFamilyFallback, contains('monospace'));
  });

  testWidgets('container radius is 14 per v4 spec', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: AppRefCode(code: 'X')),
    ));
    final container = tester.widgetList<Container>(find.byType(Container)).first;
    final decoration = container.decoration as BoxDecoration;
    final r = decoration.borderRadius as BorderRadius;
    expect(r.topLeft, const Radius.circular(14));
  });
}
