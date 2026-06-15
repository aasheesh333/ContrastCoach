import 'package:contrast_coach/core/utils/hrv_trend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty list returns zeros', () {
    final t = computeHrvTrend(const []);
    expect(t.average, 0);
    expect(t.trendPercent, 0);
  });

  test('improving trend returns positive percent', () {
    final t = computeHrvTrend([40, 41, 39, 40, 41, 40, 39, 50, 51, 50, 49, 50, 51, 50]);
    expect(t.trendPercent, closeTo(25.0, 1.0));
  });

  test('declining trend returns negative percent', () {
    final t = computeHrvTrend([50, 51, 50, 49, 50, 51, 50, 40, 41, 40, 39, 40, 41, 40]);
    expect(t.trendPercent, closeTo(-20.0, 1.0));
  });
}
