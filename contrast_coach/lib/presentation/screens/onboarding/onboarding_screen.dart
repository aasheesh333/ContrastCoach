import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _disclaimerAcknowledged = false;
  late final AnimationController _ac;
  late final Animation<double> _fade;

  @override
  void initState() { super.initState(); _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 300)); _fade = CurvedAnimation(parent: _ac, curve: Curves.easeInOut); _ac.forward(); }
  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  void _animateStep() { _ac.reset(); _ac.forward(); }

  Future<void> _next() async {
    if (_step == 2 && !_disclaimerAcknowledged) {
      showDialog<void>(context: context, builder: (_) => MedicalDisclaimerDialog(onAcknowledge: () { Navigator.of(context).pop(); setState(() => _disclaimerAcknowledged = true); _next(); }));
      return;
    }
    if (_step < 2) { setState(() => _step++); _animateStep(); }
    else { await AppPreferences.setOnboardingComplete(true); if (!mounted) return; context.go('/sign-in'); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isNarrow = w < 360;

    const steps = <_StepData>[
      _StepData(icon: LucideIcons.thermometer, title: 'HEAT.\nCOLD.\nREPEAT.', subtitle: 'Contrast therapy — alternating hot sauna and cold plunge — boosts recovery, energy, and resilience.'),
      _StepData(icon: LucideIcons.smartphone, title: 'Phone-first', subtitle: 'Quick tap to start. Timers guide you through each phase. Hands-free voice controls when you are in the zone.'),
      _StepData(icon: LucideIcons.shieldCheck, title: 'Privacy first', subtitle: AppStrings.medicalDisclaimer),
    ];
    final step = steps[_step];

    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SizedBox.expand(child: Column(children: [
      const Spacer(flex: 1),
      FadeTransition(opacity: _fade, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: isNarrow ? 80 : 100, height: isNarrow ? 80 : 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brandWarm, AppColors.brandCoral], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28)), child: Center(child: Icon(step.icon, color: AppColors.white, size: isNarrow ? 40 : 50))),
        if (_step == 0) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: cs.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(999)), child: Text('80°C', style: cs.textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w700))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm), child: Icon(LucideIcons.moveHorizontal, size: 20, color: cs.outline)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: cs.secondary.withOpacity(0.12), borderRadius: BorderRadius.circular(999)), child: Text('10°C', style: cs.textTheme.titleSmall?.copyWith(color: cs.secondary, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Tile(size: isNarrow ? 48 : 56, color: AppColors.brandWarm, icon: LucideIcons.flame, iconColor: AppColors.white, label: 'Sauna'),
            const SizedBox(width: AppSpacing.xl),
            _Tile(size: isNarrow ? 48 : 56, color: AppColors.brandCool, icon: LucideIcons.snowflake, iconColor: AppColors.white, label: 'Plunge'),
          ]),
        ],
      ])),
      const Spacer(flex: 1),
      FadeTransition(opacity: _fade, child: Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.adaptiveX(context)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(step.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: AppSpacing.lg),
        Text(step.subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
      ]))),
      const Spacer(flex: 2),
      Padding(padding: EdgeInsets.fromLTRB(AppSpacing.adaptiveX(context), 0, AppSpacing.adaptiveX(context), AppSpacing.adaptiveBottom(context)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Container(width: i == _step ? 24 : 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: i == _step ? cs.primary : cs.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(999))))),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: _step < 2 ? 'Next' : 'Get started', onPressed: _next, variant: AppButtonVariant.warm, fullWidth: true, size: AppButtonSize.large),
        const SizedBox(height: AppSpacing.md),
        if (_step > 0) TextButton(onPressed: () { setState(() => _step--); _animateStep(); }, child: Text('Back', style: TextStyle(color: cs.outline))),
      ])),
    ]))));
  }
}

class _StepData { const _StepData({required this.icon, required this.title, required this.subtitle}); final IconData icon; final String title; final String subtitle; }

class _Tile extends StatelessWidget {
  const _Tile({required this.size, required this.color, required this.icon, required this.iconColor, required this.label});
  final double size; final Color color; final IconData icon; final Color iconColor; final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: size, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Center(child: Icon(icon, color: iconColor, size: 26))),
      const SizedBox(height: 8),
      Text(label, style: cs.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }
}
