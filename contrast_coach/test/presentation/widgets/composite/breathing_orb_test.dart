import 'package:contrast_coach/presentation/widgets/composite/breathing_orb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders 170x170 orb per v4 spec', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: BreathingOrb(enabled: false))),
    ));
    final size = tester.getSize(find.byType(BreathingOrb));
    expect(size.width, 170);
    expect(size.height, 170);
  });

  testWidgets('disabled orb does not set up a ticker', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: BreathingOrb(enabled: false))),
    ));
    expect(find.byType(BreathingOrb), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('enabled orb renders with the scale-driven child',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: BreathingOrb(enabled: true))),
    ));
    expect(find.byType(BreathingOrb), findsOneWidget);
    expect(find.byType(Transform), findsOneWidget);
  });

  testWidgets('orb container has the cold radial gradient', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: BreathingOrb(enabled: false))),
    ));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(BreathingOrb),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.gradient, isA<RadialGradient>());
    expect(decoration.boxShadow!.first.color, const Color(0x992D7CF1));
  });

  testWidgets('state label shows the supplied state text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: BreathStateLabel(state: 'INHALE')),
      ),
    ));
    expect(find.text('INHALE'), findsOneWidget);
  });
}
