import 'package:flutter/material.dart';

/// Motion tokens. Durations, springs and curves used app-wide.
///
/// v4 spec (runbook §2.3): spring curve Cubic(.22, 1, .36, 1) as
/// [AppCurves.spring]; default duration 260 ms. Used for nav transitions,
/// timer phase changes, paywall sheet.
class AppMotion {
  const AppMotion._();

  static const Duration pageTransition = Duration(milliseconds: 240);
  static const Duration microInteraction = Duration(milliseconds: 180);
  static const Duration macroInteraction = Duration(milliseconds: 320);

  /// v4 default transition duration.
  static const Duration standard = Duration(milliseconds: 260);

  static const SpringDescription springDefault = SpringDescription(
    mass: 1.0,
    stiffness: 380,
    damping: 22,
  );
}

/// Named curves for shared reuse. Prefer these over inline [Cubic] literals.
class AppCurves {
  const AppCurves._();

  /// v4 spring curve — Cubic(.22, 1, .36, 1). Use for page transitions,
  /// timer phase crossfades, paywall sheet reveal.
  static const Cubic spring = Cubic(0.22, 1.0, 0.36, 1.0);
}
