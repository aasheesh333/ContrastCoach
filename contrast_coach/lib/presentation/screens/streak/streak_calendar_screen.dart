import 'package:contrast_coach/presentation/widgets/composite/streak_calendar.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class StreakCalendarScreen extends StatelessWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Streak'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('12 weeks', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const StreakCalendar(daysWithSessions: {}),
            ],
          ),
        ),
      ),
    );
  }
}
