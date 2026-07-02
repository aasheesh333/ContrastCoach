import 'package:contrast_coach/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to onboarding', (tester) async {
    await tester.pumpWidget(const ContrastCoachApp());
    await tester.pumpAndSettle();
    expect(find.text('Heat.\nCold.\nRecover smarter.'), findsOneWidget);
  });
}
