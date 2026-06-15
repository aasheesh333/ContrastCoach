import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('shows label', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: 'Email')));
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('invokes onChanged', (tester) async {
    String? changed;
    await tester.pumpWidget(_wrap(
      AppTextField(label: 'Email', onChanged: (v) => changed = v),
    ));
    await tester.enterText(find.byType(TextField), 'a@b.com');
    expect(changed, 'a@b.com');
  });

  testWidgets('shows error text', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: 'Email', errorText: 'Required')));
    expect(find.text('Required'), findsOneWidget);
  });
}
