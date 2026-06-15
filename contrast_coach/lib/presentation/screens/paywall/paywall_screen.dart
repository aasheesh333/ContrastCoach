import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Pro', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('All 10 protocols', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Full recovery score with HRV and sleep', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Health Connect integration', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              AppButton(label: r'$5.99 / month', onPressed: () => context.pop()),
              const SizedBox(height: 8),
              AppButton(label: r'$39.99 / year', onPressed: () => context.pop(), variant: AppButtonVariant.secondary),
              const SizedBox(height: 8),
              AppButton(label: r'$89.99 lifetime', onPressed: () => context.pop(), variant: AppButtonVariant.tertiary),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Restore purchases'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
