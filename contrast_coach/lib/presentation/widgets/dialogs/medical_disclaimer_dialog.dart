import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:flutter/material.dart';

class MedicalDisclaimerDialog extends StatelessWidget {
  const MedicalDisclaimerDialog({super.key, required this.onAcknowledge});
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandWarm.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.brandWarm, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              'Before you start',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.medicalDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'I understand',
              onPressed: onAcknowledge,
              variant: AppButtonVariant.warm,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
