import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class HealthConnectScreen extends StatelessWidget {
  const HealthConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Health Connect', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health data stays on your device. We never upload it.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              AppButton(
                label: 'Connect',
                onPressed: () {},
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
