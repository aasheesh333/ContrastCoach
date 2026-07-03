import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:contrast_coach/presentation/screens/settings/data_export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Data & backup renders v4 chrome (title, Cloud backup toggle, JSON/CSV/Clear-cache rowlinks, SQLCipher footer)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const DataExportScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Data & backup'), findsOneWidget);
    expect(find.textContaining('Cloud backup'), findsOneWidget);
    expect(find.textContaining('Export data (JSON)'), findsOneWidget);
    expect(find.textContaining('Export data (CSV)'), findsOneWidget);
    expect(find.text('Clear cache'), findsOneWidget);
    expect(find.textContaining('SQLCipher'), findsOneWidget);
  });
}
