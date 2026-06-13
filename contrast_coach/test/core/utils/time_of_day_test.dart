import 'package:contrast_coach/core/utils/time_of_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bucketForHour', () {
    test('5-9 is morning', () {
      expect(bucketForHour(5), DayBucket.morning);
      expect(bucketForHour(7), DayBucket.morning);
      expect(bucketForHour(9), DayBucket.morning);
    });
    test('10-13 is midday', () {
      expect(bucketForHour(10), DayBucket.midday);
      expect(bucketForHour(13), DayBucket.midday);
    });
    test('14-17 is afternoon', () {
      expect(bucketForHour(14), DayBucket.afternoon);
      expect(bucketForHour(17), DayBucket.afternoon);
    });
    test('18-20 is evening', () {
      expect(bucketForHour(18), DayBucket.evening);
      expect(bucketForHour(20), DayBucket.evening);
    });
    test('21-04 is night', () {
      expect(bucketForHour(21), DayBucket.night);
      expect(bucketForHour(0), DayBucket.night);
      expect(bucketForHour(4), DayBucket.night);
    });
  });
}
