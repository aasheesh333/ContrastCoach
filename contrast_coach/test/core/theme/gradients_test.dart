import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppGradients v4 tokens', () {
    test('splashBg has heat→purple→cold with stops', () {
      final g = AppGradients.splashBg;
      expect(g.begin, const Alignment(-0.4, -1));
      expect(g.end, const Alignment(0.4, 1));
      expect(g.colors.length, 3);
      expect(g.colors[0], AppColors.heat);
      expect(g.colors[1], const Color(0xFF7A2AA8));
      expect(g.colors[2], AppColors.cold);
      expect(g.stops, [0.0, 0.58, 1.0]);
    });

    test('heroDark is 140deg diagonal near-black pair', () {
      final g = AppGradients.heroDark;
      // 140deg in css-gradient-to-flutter-mapping yields (-0.27, -1) -> (0.27, 1).
      expect(g.begin, const Alignment(-0.27, -1));
      expect(g.end, const Alignment(0.27, 1));
      expect(g.colors.length, 2);
      expect(g.colors[0], const Color(0xFF12121A));
      expect(g.colors[1], const Color(0xFF25252F));
    });

    test('heat is heat→coral 120deg diagonal (matches .btn)', () {
      final g = AppGradients.heat;
      expect(g.begin, const Alignment(-0.5, -1));
      expect(g.end, const Alignment(0.5, 1));
      expect(g.colors, [AppColors.heat, AppColors.coral]);
    });

    test('scoreTextShare is heat→cold2 120deg', () {
      final g = AppGradients.scoreTextShare;
      expect(g.begin, const Alignment(-0.5, -1));
      expect(g.end, const Alignment(0.5, 1));
      expect(g.colors, [AppColors.heat, AppColors.cold2]);
    });

    test('shareCard is near-black→ember 160deg', () {
      final g = AppGradients.shareCard;
      expect(g.begin, const Alignment(-0.4, -1));
      expect(g.end, const Alignment(0.4, 1));
      expect(g.colors, [const Color(0xFF12121A), const Color(0xFF3A1E12)]);
    });

    test('breathwork is deep-blue→near-black 160deg', () {
      final g = AppGradients.breathwork;
      expect(g.begin, const Alignment(-0.4, -1));
      expect(g.end, const Alignment(0.4, 1));
      expect(g.colors, [const Color(0xFF0A2A5C), const Color(0xFF0C0C0E)]);
    });

    test('btnPrimary is heat→coral 120deg', () {
      final g = AppGradients.btnPrimary;
      expect(g.begin, const Alignment(-0.5, -1));
      expect(g.end, const Alignment(0.5, 1));
      expect(g.colors, [AppColors.heat, AppColors.coral]);
    });

    test('btnCold is cold→cold2 120deg', () {
      final g = AppGradients.btnCold;
      expect(g.begin, const Alignment(-0.5, -1));
      expect(g.end, const Alignment(0.5, 1));
      expect(g.colors, [AppColors.cold, AppColors.cold2]);
    });

    test('btnDelete is error→warm red 120deg', () {
      final g = AppGradients.btnDelete;
      expect(g.begin, const Alignment(-0.5, -1));
      expect(g.end, const Alignment(0.5, 1));
      expect(g.colors, [AppColors.error, const Color(0xFFFF6B68)]);
    });

    test('sessionWarm radial colors + focal', () {
      final g = AppGradients.sessionWarm;
      expect(g.center, const Alignment(0.5, 0.0));
      expect(g.focal, const Alignment(0.5, 0.0));
      expect(g.focalRadius, 0.8);
      expect(g.radius, 1.2);
      expect(g.colors, [const Color(0xFF7A2A0E), AppColors.lightInk]);
    });

    test('sessionCold radial colors + focal', () {
      final g = AppGradients.sessionCold;
      expect(g.center, const Alignment(0.5, 0.0));
      expect(g.focal, const Alignment(0.5, 0.0));
      expect(g.focalRadius, 0.8);
      expect(g.radius, 1.2);
      expect(g.colors, [const Color(0xFF0D3A7A), AppColors.lightInk]);
    });

    test('scoreText is horizontal heat→cold', () {
      final g = AppGradients.scoreText;
      expect(g.begin, Alignment.centerLeft);
      expect(g.end, Alignment.centerRight);
      expect(g.colors, [AppColors.heat, AppColors.cold]);
    });

    test('bodyGlow has three colors with stops', () {
      final g = AppGradients.bodyGlow;
      expect(g.begin, Alignment.topLeft);
      expect(g.end, Alignment.topRight);
      expect(g.colors.length, 3);
      expect(g.colors[0], const Color(0x80FFE1D0));
      expect(g.colors[1], const Color(0xFFECEEF3));
      expect(g.colors[2], const Color(0x80D4E4FF));
      expect(g.stops, [0.0, 0.5, 1.0]);
    });

    test('legacy gradients heat/contrast/contrastHorizontal unchanged', () {
      expect(AppGradients.heat.colors,
          [AppColors.brandWarm, AppColors.brandCoral]);
      expect(AppGradients.contrast.colors,
          [AppColors.brandWarm, AppColors.brandCool]);
      expect(AppGradients.contrastHorizontal.colors,
          [AppColors.brandWarm, AppColors.brandCool]);
    });
  });

  group('AppShadows v4 cardSoftFor', () {
    testWidgets('light mode returns v4 soft values', (tester) async {
      late List<BoxShadow> captured;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: Builder(builder: (context) {
          captured = AppShadows.cardSoftFor(context);
          return const SizedBox.shrink();
        }),
      ));
      expect(captured.length, 1);
      final s = captured.single;
      expect(s.color, const Color(0x2814142D));
      expect(s.blurRadius, 24);
      expect(s.offset, const Offset(0, 8));
      expect(s.spreadRadius, -16);
    });

    testWidgets('dark mode returns stronger dark soft values', (tester) async {
      late List<BoxShadow> captured;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(builder: (context) {
          captured = AppShadows.cardSoftFor(context);
          return const SizedBox.shrink();
        }),
      ));
      expect(captured.single.color, const Color(0x66000000));
      expect(captured.single.blurRadius, 24);
      expect(captured.single.offset, const Offset(0, 8));
      expect(captured.single.spreadRadius, -16);
    });
  });

  group('AppShadows v4 cardStrongFor', () {
    testWidgets('light mode returns v4 raised values', (tester) async {
      late List<BoxShadow> captured;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: Builder(builder: (context) {
          captured = AppShadows.cardStrongFor(context);
          return const SizedBox.shrink();
        }),
      ));
      final s = captured.single;
      expect(s.color, const Color(0x6614142D));
      expect(s.blurRadius, 44);
      expect(s.offset, const Offset(0, 20));
      expect(s.spreadRadius, -22);
    });

    testWidgets('dark mode returns stronger dark raised values', (tester) async {
      late List<BoxShadow> captured;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(builder: (context) {
          captured = AppShadows.cardStrongFor(context);
          return const SizedBox.shrink();
        }),
      ));
      final s = captured.single;
      expect(s.color, const Color(0x99000000));
      expect(s.blurRadius, 44);
      expect(s.offset, const Offset(0, 20));
      expect(s.spreadRadius, -22);
    });
  });

  group('AppShadows static light getters', () {
    test('cardSoft matches v4 soft light', () {
      final s = AppShadows.cardSoft.single;
      expect(s.color, const Color(0x2814142D));
      expect(s.blurRadius, 24);
      expect(s.offset, const Offset(0, 8));
      expect(s.spreadRadius, -16);
    });

    test('cardMedium matches v4 medium light', () {
      final s = AppShadows.cardMedium.single;
      expect(s.color, const Color(0x3314142D));
      expect(s.blurRadius, 32);
      expect(s.offset, const Offset(0, 12));
      expect(s.spreadRadius, -16);
    });

    test('cardStrong matches v4 raised light', () {
      final s = AppShadows.cardStrong.single;
      expect(s.color, const Color(0x6614142D));
      expect(s.blurRadius, 44);
      expect(s.offset, const Offset(0, 20));
      expect(s.spreadRadius, -22);
    });

    test('pill unchanged (heat glow)', () {
      final s = AppShadows.pill.single;
      expect(s.blurRadius, 18);
      expect(s.offset, const Offset(0, 8));
    });
  });
}
