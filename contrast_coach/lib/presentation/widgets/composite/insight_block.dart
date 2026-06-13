import 'package:flutter/material.dart';

class InsightBlock extends StatelessWidget {
  const InsightBlock({
    super.key,
    required this.heroMetric,
    required this.title,
    required this.body,
  });
  final String heroMetric;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heroMetric, style: tt.displayMedium),
          const SizedBox(height: 8),
          Text(title, style: tt.titleLarge),
          const SizedBox(height: 4),
          Text(body, style: tt.bodyMedium),
        ],
      ),
    );
  }
}
