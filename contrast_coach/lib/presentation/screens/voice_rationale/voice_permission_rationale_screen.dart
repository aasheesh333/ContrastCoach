import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VoicePermissionRationaleScreen extends StatelessWidget {
  const VoicePermissionRationaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Voice control', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why we ask', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text(
                'Voice commands let you control sessions hands-free ("Hey Coach, next phase"). '
                'No audio is recorded or transmitted. All processing is on-device.',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              AppButton(label: 'Allow', onPressed: () => context.pop()),
              const SizedBox(height: 8),
              AppButton(label: 'Not now', onPressed: () => context.pop(), variant: AppButtonVariant.text),
            ],
          ),
        ),
      ),
    );
  }
}
