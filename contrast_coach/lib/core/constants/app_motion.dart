import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const Duration pageTransition = Duration(milliseconds: 240);
  static const Duration microInteraction = Duration(milliseconds: 180);
  static const Duration macroInteraction = Duration(milliseconds: 320);

  static const SpringDescription springDefault = SpringDescription(
    mass: 1.0,
    stiffness: 380,
    damping: 22,
  );
}
