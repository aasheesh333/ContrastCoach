import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Delete account', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('This permanently removes all your data.'),
              const Spacer(),
              AppButton(
                label: 'Delete account',
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
