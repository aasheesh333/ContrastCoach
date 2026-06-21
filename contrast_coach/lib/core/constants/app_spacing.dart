import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();
  static const double unit = 4, xxs = 2, xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24, xxxl = 32, huge = 40, massive = 56;
  static const double pageHorizontal = 20, pageTop = 12, pageBottom = 24, sectionGap = 28;
  static EdgeInsets get sectionHeaderPadding => const EdgeInsets.fromLTRB(2, 12, 2, 8);
  static double adaptiveX(BuildContext c) => MediaQuery.of(c).size.width < 360 ? 12.0 : 20.0;
  static double adaptiveTop(BuildContext c) => MediaQuery.of(c).size.width < 360 ? 8.0 : 12.0;
  static double adaptiveBottom(BuildContext c) => MediaQuery.of(c).size.width < 360 ? 16.0 : 24.0;
  static EdgeInsets adaptivePage(BuildContext c) => EdgeInsets.fromLTRB(adaptiveX(c), adaptiveTop(c), adaptiveX(c), adaptiveBottom(c));
}

class AppShadows {
  const AppShadows._();
  static List<BoxShadow> get cardSoft => [const BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 2))];
  static List<BoxShadow> get cardMedium => [const BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 6))];
  static List<BoxShadow> get pill => [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 8))];
}
