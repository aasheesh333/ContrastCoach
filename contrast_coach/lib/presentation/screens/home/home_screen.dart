import 'package:contrast_coach/presentation/widgets/composite/hero_start_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/quick_stats_row.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Home'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              HeroStartCard(),
              SizedBox(height: 16),
              QuickStatsRow(streakDays: 0, avgDurationMin: 0, lastScore: null),
            ],
          ),
        ),
      ),
    );
  }
}
