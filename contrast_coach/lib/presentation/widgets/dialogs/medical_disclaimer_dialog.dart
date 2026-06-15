import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:flutter/material.dart';

class MedicalDisclaimerDialog extends StatelessWidget {
  const MedicalDisclaimerDialog({super.key, required this.onAcknowledge});
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Before you start'),
      content: const Text(AppStrings.medicalDisclaimer),
      actions: [
        AppButton(label: 'I understand', onPressed: onAcknowledge, variant: AppButtonVariant.primary),
      ],
    );
  }
}
