import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 onboarding is a single bottom-anchored hero page on a
/// heat→purple (60%)→cold gradient. The "Continue" / "Get started →" button
/// acknowledges the medical disclaimer on first tap (modal), then persists the
/// onboarded flag and routes to /sign-in. A top-right `.skip` link routes
/// immediately without preserving the disclaimer acknowledgement.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _disclaimerAcknowledged = false;
  bool _saving = false;

  Future<void> _finish({required bool acknowledged}) async {
    if (!acknowledged) {
      _showDisclaimer();
      return;
    }
    setState(() => _saving = true);
    final ok = await AppPreferences.setOnboardingComplete(true);
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Please try again.')),
      );
      return;
    }
    context.go('/sign-in');
  }

  Future<void> _skip() async {
    setState(() => _saving = true);
    await AppPreferences.setOnboardingComplete(true);
    if (!mounted) return;
    context.go('/sign-in');
  }

  void _showDisclaimer() {
    showDialog<void>(
      context: context,
      builder: (_) => MedicalDisclaimerDialog(
        onAcknowledge: () {
          Navigator.of(context).pop();
          setState(() => _disclaimerAcknowledged = true);
          _finish(acknowledged: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _kOnboardingGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 58,
                right: 22,
                child: GestureDetector(
                  onTap: _saving ? null : _skip,
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xD9FFFFFF),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 46),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 3-dot pager - 7x7 round white-.4 inactive, 24x7 white active.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _PagerDot(active: true),
                        SizedBox(width: 6),
                        _PagerDot(active: false),
                        SizedBox(width: 6),
                        _PagerDot(active: false),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Heat.\nCold.\nRecover smarter.',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        height: 1.12,
                        color: AppColors.lightInk,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ContrastCoach turns cold plunge + sauna routines into '
                      'measurable recovery data, training your nervous system '
                      'to anchor under stress.',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _WhiteHeatCta(
                      label: 'Get started →',
                      loading: _saving,
                      onTap: () => _finish(acknowledged: _disclaimerAcknowledged),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const LinearGradient _kOnboardingGradient = LinearGradient(
  begin: Alignment(-0.4, -1),
  end: Alignment(0.4, 1),
  colors: [AppColors.heat, Color(0xFF7A2AA8), AppColors.cold],
  stops: [0.0, 0.6, 1.0],
);

class _PagerDot extends StatelessWidget {
  const _PagerDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: active ? 24 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppColors.lightInk : const Color(0x66FFFFFF),
        borderRadius: active
            ? BorderRadius.circular(4)
            : const BorderRadius.all(Radius.circular(3.5)),
      ),
    );
  }
}

class _WhiteHeatCta extends StatelessWidget {
  const _WhiteHeatCta({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = loading;
    return Material(
      color: disabled ? const Color(0xCCFFFFFF) : AppColors.lightInk,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.heat),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.heat,
                  ),
                ),
        ),
      ),
    );
  }
}
