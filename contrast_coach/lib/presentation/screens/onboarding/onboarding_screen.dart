import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _disclaimerAcknowledged = false;

  void _next() {
    if (_step == 2 && !_disclaimerAcknowledged) {
      showDialog<void>(
        context: context,
        builder: (_) => MedicalDisclaimerDialog(
          onAcknowledge: () {
            Navigator.of(context).pop();
            setState(() => _disclaimerAcknowledged = true);
            _next();
          },
        ),
      );
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (title, body) = switch (_step) {
      0 => (AppStrings.onboardingStep1Title, AppStrings.onboardingStep1Body),
      1 => (AppStrings.onboardingStep2Title, AppStrings.onboardingStep2Body),
      _ => (AppStrings.onboardingStep3Title, AppStrings.onboardingStep3Body),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_step == 0 ? '01' : _step == 1 ? '02' : '03',
                  style: tt.labelSmall?.copyWith(letterSpacing: 2)),
              const SizedBox(height: 24),
              Text(title, style: tt.displayMedium),
              const SizedBox(height: 16),
              Text(body, style: tt.bodyLarge),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    AppButton(
                      label: 'Back',
                      onPressed: () => setState(() => _step--),
                      variant: AppButtonVariant.text,
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton(
                    label: _step == 2 ? 'Continue to sign in' : 'Continue',
                    onPressed: _next,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
