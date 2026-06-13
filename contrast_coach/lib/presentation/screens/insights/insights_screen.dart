import 'package:contrast_coach/presentation/widgets/composite/insight_block.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Insights'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Not medical advice. For informational purposes only.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              InsightBlock(heroMetric: '12', title: 'Total sessions', body: 'Last 30 days.'),
              InsightBlock(heroMetric: '22m', title: 'Avg duration', body: 'Down from 26m last month.'),
              InsightBlock(heroMetric: 'Recovery', title: 'Best protocol', body: 'Standard Recovery, 3x weekly.'),
              InsightBlock(heroMetric: '+23m', title: 'Sleep correlation', body: 'Sessions before 7pm correlate with +23m sleep.'),
            ],
          ),
        ),
      ),
    );
  }
}
