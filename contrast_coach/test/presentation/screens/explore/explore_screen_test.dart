import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/explore/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _protocolsJson = '''
{
  "version": 1,
  "protocols": [
    {
      "id": "recovery_standard",
      "name": "Standard Recovery",
      "description": "Balanced contrast",
      "category": "recovery",
      "difficulty": "intermediate",
      "isPro": false,
      "rounds": 3,
      "phases": [
        {"type": "sauna", "duration": 900, "targetTempC": 80},
        {"type": "cold", "duration": 120, "targetTempC": 12}
      ]
    },
    {
      "id": "energy_morning",
      "name": "Morning Energy",
      "description": "Wake-up",
      "category": "energy",
      "difficulty": "beginner",
      "isPro": false,
      "rounds": 2,
      "phases": [
        {"type": "sauna", "duration": 600, "targetTempC": 75},
        {"type": "cold", "duration": 60, "targetTempC": 15}
      ]
    },
    {
      "id": "sleep_evening",
      "name": "Sleep Recovery",
      "description": "Wind down",
      "category": "sleep",
      "difficulty": "beginner",
      "isPro": true,
      "rounds": 2,
      "phases": [
        {"type": "sauna", "duration": 720, "targetTempC": 70},
        {"type": "cold", "duration": 90, "targetTempC": 18}
      ]
    },
    {
      "id": "immunity_weekly",
      "name": "Immune Boost",
      "description": "Resilience",
      "category": "immunity",
      "difficulty": "advanced",
      "isPro": true,
      "rounds": 4,
      "phases": [
        {"type": "sauna", "duration": 720, "targetTempC": 85},
        {"type": "cold", "duration": 60, "targetTempC": 10}
      ]
    },
    {
      "id": "wim_hof_classic",
      "name": "Wim Hof Style",
      "description": "Cold hardening",
      "category": "energy",
      "difficulty": "advanced",
      "isPro": true,
      "rounds": 4,
      "phases": [
        {"type": "cold", "duration": 120, "targetTempC": 8}
      ]
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = const StringCodec().decodeMessage(message);
      if (key == 'assets/protocols.json') {
        return const StringCodec().encodeMessage(_protocolsJson);
      }
      return null;
    });
  });

  Future<void> buildExplore(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const ExploreScreen(),
      ),
    );
    // Resolve async asset load with explicit pumps (no pumpAndSettle).
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders the v4 .name "Explore" 28/w800/ls-.7', (tester) async {
    await buildExplore(tester);
    final title = find.text('Explore');
    expect(title, findsOneWidget);
    final text = tester.widget<Text>(title);
    expect(text.style?.fontSize, 28);
    expect(text.style?.fontWeight, FontWeight.w800);
    expect(text.style?.letterSpacing, -0.7);
  });

  testWidgets('renders all 5 filter chips (All/Recovery/Energy/Sleep/Cold)',
      (tester) async {
    await buildExplore(tester);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Recovery'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('Cold'), findsOneWidget);
  });

  testWidgets('renders the 30-Day Cold Challenge program hero', (tester) async {
    await buildExplore(tester);
    expect(find.text('❄️ 30-Day Cold Challenge'), findsOneWidget);
    expect(find.text('Day 12 of 30'), findsOneWidget);
  });

  testWidgets('renders "All protocols" section header', (tester) async {
    await buildExplore(tester);
    expect(find.text('All protocols'), findsOneWidget);
  });

  testWidgets('renders the Custom tile since no custom protocol in assets',
      (tester) async {
    await buildExplore(tester);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Build your own'), findsOneWidget);
  });
}
