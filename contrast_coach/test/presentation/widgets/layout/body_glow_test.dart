import 'package:contrast_coach/presentation/widgets/layout/body_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BodyGlow builds without throwing and paints',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodyGlow(child: const SizedBox.shrink()),
        ),
      ),
    );
    expect(find.byType(BodyGlow), findsOneWidget);
    expect(find.byType(CustomPaint), findsNWidgets(1));
  });
}
