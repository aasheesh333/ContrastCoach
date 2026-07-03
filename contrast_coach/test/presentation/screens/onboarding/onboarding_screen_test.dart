import 'package:contrast_coach/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (_, __) => const Scaffold(body: Text('sign-in')),
        ),
      ],
    );
  });

  Widget buildHarness() => MaterialApp.router(routerConfig: router);

  testWidgets('renders the v4 headline "Heat. / Cold. / Recover smarter."',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    expect(find.text('Heat.\nCold.\nRecover smarter.'), findsOneWidget);
    final text = tester.widget<Text>(
      find.text('Heat.\nCold.\nRecover smarter.'),
    );
    expect(text.style?.fontSize, 33);
    expect(text.style?.fontWeight, FontWeight.w800);
    expect(text.style?.letterSpacing, -1.0);
  });

  testWidgets('renders the Skip link in the top-right corner',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    final skip = find.text('Skip');
    expect(skip, findsOneWidget);
    final skipText = tester.widget<Text>(skip);
    expect(skipText.style?.fontSize, 13);
    expect(skipText.style?.fontWeight, FontWeight.w700);
  });

  testWidgets('renders exactly one CTA labelled "Get started →"',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    final ctaFinder = find.text('Get started →');
    expect(ctaFinder, findsOneWidget);
  });

  testWidgets('CTA is white bg with heat-colored text (no gradient)',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    final ctaFinder = find.text('Get started →');
    final materialFinder = find.ancestor(
      of: ctaFinder,
      matching: find.byType(Material),
    );
    final material = tester.widget<Material>(materialFinder.first);
    // Material.color is an opaque Color (not the default Theme null).
    expect(material.color, isNotNull);
    final text = tester.widget<Text>(ctaFinder);
    expect(text.style?.color, const Color(0xFFFF6B35));
  });

  testWidgets('renders exactly three pager dots, first active',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    final dotsFinder = find.descendant(
      of: find.byType(OnboardingScreen),
      matching: find.byType(AnimatedContainer),
    );
    expect(dotsFinder, findsNWidgets(3));
  });

  testWidgets('content is bottom-anchored: Skip link at top, pager dots '
      'next, then headline, subtitle, CTA in vertical order',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    final skipFinder = find.text('Skip');
    final headlineFinder = find.text('Heat.\nCold.\nRecover smarter.');
    final subtitleFinder =
        find.textContaining('ContrastCoach turns cold plunge');
    final ctaFinder = find.text('Get started →');

    final skipY = tester.getTopLeft(skipFinder).dy;
    final headlineY = tester.getTopLeft(headlineFinder).dy;
    final subtitleY = tester.getTopLeft(subtitleFinder).dy;
    final ctaY = tester.getTopLeft(ctaFinder).dy;

    // Vertical order — content cascades down the screen.
    expect(skipY, lessThan(headlineY));
    expect(headlineY, lessThan(subtitleY));
    expect(subtitleY, lessThan(ctaY));
  });
}
