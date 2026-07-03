class AppShapes {
  const AppShapes._();

  static const double small = 14;
  static const double large = 26;
  static const double card = cardLarge;

  // Cards
  @Deprecated('Use small')
  static const double cardSmall = 14;
  static const double cardMedium = 16;
  static const double cardLarge = 20;
  @Deprecated('Use large')
  static const double cardXL = 26;

  // Buttons
  static const double buttonPill = 999; // full pill
  static const double buttonStandard = 16;

  // Sheets
  static const double sheetTop = 28;

  // Heatmap
  static const double heatmapCell = 28;
  static const double heatmapRadius = 6;

  // Hero (active session full-screen)
  static const double heroFull = 32;
}
