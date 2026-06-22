import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _disclaimerAcknowledged = false;

  Future<void> _next() async {
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
      await AppPreferences.setOnboardingComplete(true);
      if (!mounted) return;
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 0),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _PageDots(active: _step, total: 3),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _StepContent(key: ValueKey(_step), step: _step),
                  ),
                  const Spacer(),
                  const _Tagline(text: AppStrings.onboardingStep1Tagline),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: _step == 2 ? 'Get started' : 'Continue',
                    onPressed: () => _next(),
                    variant: AppButtonVariant.warm,
                    fullWidth: true,
                    size: AppButtonSize.large,
                  ),
                  if (_step > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
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
          illustration: const _SessionReadyIllustration(),
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
        const SizedBox(height: AppSpacing.huge),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            height: 1.05,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
            height: 1.5,
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
      key: key,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.brandWarm.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(LucideIcons.shieldCheck, color: AppColors.brandWarm, size: 36),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Text(
          'Private by default.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _PrivacyRow(
          icon: LucideIcons.smartphone,
          color: AppColors.brandWarm,
          title: 'Stays on device',
          subtitle: 'Nothing leaves your phone without permission',
        ),
        const SizedBox(height: AppSpacing.md),
        const _PrivacyRow(
          icon: LucideIcons.heartPulse,
          color: AppColors.brandCool,
          title: 'Health data local',
          subtitle: 'Heart rate and HRV never reach our servers',
        ),
        const SizedBox(height: AppSpacing.md),
        const _PrivacyRow(
          icon: LucideIcons.trash2,
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
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: 20,
      elevation: AppCardElevation.soft,
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
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                    height: 1.35,
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

/// Layered illustration: a warm radial with a cool core. No emoji.
class _ThermalIllustration extends StatelessWidget {
  const _ThermalIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFFFE0CC), Color(0xFFFF6B35)],
                stops: [0.45, 1.0],
              ),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFD7E5FF), Color(0xFF2D7CF1)],
                stops: [0.35, 1.0],
              ),
            ),
            child: const Center(
              child: Icon(LucideIcons.zap, color: AppColors.white, size: 40),
            ),
          ),
          Positioned(
            top: 16,
            right: 24,
            child: _Pill(label: '80°C', color: AppColors.brandWarm),
          ),
          Positioned(
            bottom: 16,
            left: 24,
            child: _Pill(label: '10°C', color: AppColors.brandCool),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone + sauna + cold visual; no emoji.
class _SessionReadyIllustration extends StatelessWidget {
  const _SessionReadyIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmBeige,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Tile(
            size: 70,
            color: AppColors.charcoal,
            icon: LucideIcons.lock,
            iconColor: AppColors.white,
            label: 'Phone',
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.arrowRight, color: AppColors.brandWarm, size: 20),
          ),
          const _Tile(
            size: 70,
            color: AppColors.brandWarm,
            icon: LucideIcons.flame,
            iconColor: AppColors.white,
            label: 'Sauna',
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.arrowRight, color: AppColors.brandCool, size: 20),
          ),
          const _Tile(
            size: 70,
            color: AppColors.brandCool,
            icon: LucideIcons.snowflake,
            iconColor: AppColors.white,
            label: 'Plunge',
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.size,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.label,
  });
  final double size;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 26)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.midGray,
          ),
        ),
      ],
    );
  }
}
