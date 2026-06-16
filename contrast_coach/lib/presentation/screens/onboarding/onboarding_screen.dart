import 'package:contrast_coach/core/constants/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _PageDots(active: _step, total: 3),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _StepContent(
                  key: ValueKey(_step),
                  step: _step,
                ),
              ),
              const Spacer(),
              _Tagline(text: AppStrings.onboardingStep1Tagline),
              const SizedBox(height: 16),
              AppButton(
                label: _step == 2 ? 'Get started' : 'Continue',
                onPressed: _next,
                variant: AppButtonVariant.warm,
                fullWidth: true,
                size: AppButtonSize.large,
              ),
              if (_step > 0) ...[
                const SizedBox(height: 8),
                AppButton(
                  label: 'Back',
                  onPressed: () => setState(() => _step--),
                  variant: AppButtonVariant.text,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.active, required this.total});
  final int active;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == active;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.brandWarm : AppColors.lightGray,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({super.key, required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      0 => _StepHero(
          key: key,
          title: 'HEAT.\nCOLD.\nREPEAT.',
          body: AppStrings.onboardingStep1Body,
          illustration: const _ThermalIllustration(),
        ),
      1 => _StepHero(
          key: key,
          title: AppStrings.onboardingStep2Title,
          body: AppStrings.onboardingStep2Body,
          illustration: const _PhoneInLockerIllustration(),
        ),
      _ => _StepPrivacy(key: key),
    };
  }
}

class _StepHero extends StatelessWidget {
  const _StepHero({
    super.key,
    required this.title,
    required this.body,
    required this.illustration,
  });
  final String title;
  final String body;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        illustration,
        const SizedBox(height: 32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            height: 1.05,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.darkGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StepPrivacy extends StatelessWidget {
  const _StepPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.brandWarm.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.shield_outlined, color: AppColors.brandWarm, size: 40),
        ),
        const SizedBox(height: 28),
        const Text(
          'Private by default.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        _PrivacyRow(
          icon: Icons.phone_iphone,
          color: AppColors.brandWarm,
          title: 'Stays on device',
          subtitle: 'Nothing leaves your phone without permission',
        ),
        const SizedBox(height: 12),
        _PrivacyRow(
          icon: Icons.favorite_outline,
          color: AppColors.brandCool,
          title: 'Health data local',
          subtitle: 'Heart rate and HRV never reach our servers',
        ),
        const SizedBox(height: 12),
        _PrivacyRow(
          icon: Icons.delete_outline,
          color: AppColors.brandCoral,
          title: 'Delete anytime',
          subtitle: 'One tap and everything is gone',
        ),
      ],
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.midGray,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ThermalIllustration extends StatelessWidget {
  const _ThermalIllustration();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer warm ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFE0CC), Color(0xFFFF6B35)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          // Inner cool circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFD7E5FF), Color(0xFF2D7CF1)],
                stops: [0.3, 1.0],
              ),
            ),
            child: const Center(
              child: Text(
                '⚡',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInLockerIllustration extends StatelessWidget {
  const _PhoneInLockerIllustration();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmBeige,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Phone in locker
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.charcoal, width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.lock_outline, color: AppColors.white, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Phone',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.midGray,
                ),
              ),
            ],
          ),
          // Arrow
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_forward, color: AppColors.brandWarm, size: 20),
          ),
          // Sauna + cold icons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandWarm, AppColors.brandCool],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🧖', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Session',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.midGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
