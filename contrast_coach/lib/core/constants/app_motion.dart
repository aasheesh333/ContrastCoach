import 'package:flutter/material.dart';

class AppCurves {
  const AppCurves._();

  /// Spring curve matching CSS `cubic-bezier(.22,1,.36,1)`.
  static const Cubic spring = Cubic(0.22, 1, 0.36, 1);

  /// Switch-thumb overshoot curve matching CSS `cubic-bezier(.3,1.4,.5,1)`.
  static const Cubic switchThumb = Cubic(0.3, 1.4, 0.5, 1);
}

class AppMotion {
  const AppMotion._();

  static const Duration pageTransition = Duration(milliseconds: 240);
  static const Duration microInteraction = Duration(milliseconds: 180);
  static const Duration macroInteraction = Duration(milliseconds: 320);
  static const Duration defaultDuration = Duration(milliseconds: 260);

  static const SpringDescription springDefault = SpringDescription(
    mass: 1.0,
    stiffness: 380,
    damping: 22,
  );
}
