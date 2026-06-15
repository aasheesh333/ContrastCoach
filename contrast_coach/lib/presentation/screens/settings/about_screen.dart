import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'About', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.appName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(AppStrings.appTagline, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(AppStrings.medicalDisclaimer, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
