import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> buildHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const HomeScreen(),
      ),
    );
    // FirebaseAuth.instance not initialized in test env → _load() short-circuits
    // synchronously on initState. Pump only the initial frame.
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('renders "Welcome 👋" header when no profile', (tester) async {
    await buildHome(tester);
    expect(find.text('Welcome 👋'), findsOneWidget);
  });

  testWidgets('renders a greeting line above the name', (tester) async {
    await buildHome(tester);
    final greetings = ['Good morning', 'Good afternoon', 'Good evening',
        'Winding down', 'Resting up'];
    final found = greetings.any((g) => find.text(g).evaluate().isNotEmpty);
    expect(found, isTrue);
  });

  testWidgets('renders the dark hero card with readiness label', (tester) async {
    await buildHome(tester);
    expect(find.text("TODAY'S READINESS"), findsOneWidget);
    // Empty stats → default score 82 → 'Strong — go hard 🔥'
    expect(find.text('Strong — go hard 🔥'), findsOneWidget);
  });

  testWidgets('renders the gauge "RECOVERY" inner label', (tester) async {
    await buildHome(tester);
    expect(find.text('RECOVERY'), findsOneWidget);
  });

  testWidgets('renders streak + avg pills', (tester) async {
    await buildHome(tester);
    expect(find.textContaining('day streak'), findsOneWidget);
    expect(find.textContaining('m avg'), findsOneWidget);
  });

  testWidgets('renders the "Quick start" section header + "Explore" trailing',
      (tester) async {
    await buildHome(tester);
    expect(find.text('Quick start'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });

  testWidgets('renders the two quick-start tiles', (tester) async {
    await buildHome(tester);
    expect(find.text('Standard Recovery'), findsOneWidget);
    expect(find.text('Breathwork'), findsOneWidget);
  });

  testWidgets('renders the heat CTA "▶️ Start session"', (tester) async {
    await buildHome(tester);
    final cta = find.text('▶️ Start session');
    expect(cta, findsOneWidget);
  });

  testWidgets('renders "Build a custom protocol" text button', (tester) async {
    await buildHome(tester);
    final label = find.text('Build a custom protocol');
    expect(label, findsOneWidget);
    final text = tester.widget<Text>(label);
    expect(text.style?.color, AppColors.heat);
  });
}
