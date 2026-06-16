import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_shapes.dart';
import 'package:flutter/material.dart';

/// Heatmap calendar with 4 intensity levels of orange.
/// Renders last 84 days (12 weeks × 7 days).
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({
    super.key,
    required this.daysWithSessions,
    this.intensity,
    this.weeks = 12,
  });

  /// Set of dates that have sessions.
  final Set<DateTime> daysWithSessions;

  /// Optional: count of sessions per day for intensity.
  final Map<DateTime, int>? intensity;

  final int weeks;

  Color _intensityColor(int count) {
    if (count <= 0) return AppColors.heatmap0;
    if (count == 1) return AppColors.heatmap1;
    if (count == 2) return AppColors.heatmap2;
    if (count == 3) return AppColors.heatmap3;
    return AppColors.heatmap4;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalDays = weeks * 7;
    final start = today.subtract(Duration(days: totalDays - 1));

    // Day labels (Mon, Wed, Fri)
    final dayLabels = ['', 'M', '', 'W', '', 'F', ''];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day-of-week header row
        Row(
          children: dayLabels
              .map((d) => SizedBox(
                    width: AppShapes.heatmapCell + 4,
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.midGray,
                        height: 1.0,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        // Build the grid
        for (int w = 0; w < weeks; w++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (int d = 0; d < 7; d++)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _Cell(
                      date: start.add(Duration(days: w * 7 + d)),
                      today: today,
                      isSession: (DateTime d) {
                        if (intensity != null) {
                          return intensity![DateTime(d.year, d.month, d.day)] ?? 0;
                        }
                        return daysWithSessions.contains(DateTime(d.year, d.month, d.day))
                            ? 1
                            : 0;
                      }(start.add(Duration(days: w * 7 + d))),
                      color: _intensityColor(
                        intensity?[DateTime(
                              start.add(Duration(days: w * 7 + d)).year,
                              start.add(Duration(days: w * 7 + d)).month,
                              start.add(Duration(days: w * 7 + d)).day,
                            )] ??
                            (daysWithSessions.contains(DateTime(
                                  start.add(Duration(days: w * 7 + d)).year,
                                  start.add(Duration(days: w * 7 + d)).month,
                                  start.add(Duration(days: w * 7 + d)).day,
                                ))
                                ? 1
                                : 0),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.date, required this.today, required this.isSession, required this.color});
  final DateTime date;
  final DateTime today;
  final int isSession;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    return Container(
      width: AppShapes.heatmapCell,
      height: AppShapes.heatmapCell,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppShapes.heatmapRadius),
        border: isToday
            ? Border.all(color: AppColors.charcoal, width: 2)
            : null,
      ),
    );
  }
}
