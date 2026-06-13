import 'package:flutter/material.dart';

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({super.key, required this.daysWithSessions});
  final Set<DateTime> daysWithSessions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 83));
    final days = <Widget>[];
    for (var i = 0; i < 84; i++) {
      final d = start.add(Duration(days: i));
      final has = daysWithSessions.contains(DateTime(d.year, d.month, d.day));
      days.add(
        Container(
          margin: const EdgeInsets.all(1),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: has ? cs.onSurface : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }
    return Wrap(spacing: 0, runSpacing: 0, children: days);
  }
}
