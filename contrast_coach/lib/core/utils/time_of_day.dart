enum DayBucket { morning, midday, afternoon, evening, night }

DayBucket bucketForHour(int hour) {
  if (hour >= 5 && hour <= 9) return DayBucket.morning;
  if (hour >= 10 && hour <= 13) return DayBucket.midday;
  if (hour >= 14 && hour <= 17) return DayBucket.afternoon;
  if (hour >= 18 && hour <= 20) return DayBucket.evening;
  return DayBucket.night;
}

bool isLateNight(DateTime dt) => dt.hour >= 21 || dt.hour <= 4;
bool isMorning(DateTime dt) => dt.hour >= 5 && dt.hour <= 9;
