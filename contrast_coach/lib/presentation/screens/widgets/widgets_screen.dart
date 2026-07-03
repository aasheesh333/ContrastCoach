import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

/// v4 Widgets — mockup `#widgets`.
///
/// `.appbar` "Home-screen widgets" h2.
/// 3 `.widget` preview cards, each with bold uppercase label, big number,
///   subtext, gradient bg (heat / dark / cold).
/// `.btn` "Add to home screen".
class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(
          title: 'Home-screen widgets', showBackButton: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _WidgetCard(
                label: 'STREAK',
                value: '🔥 7 days',
                subtext: 'Tap to start today\'s session',
                gradient: AppGradients.btnPrimary,
                textColor: Colors.white,
                labelOpacity: 0.85,
              ),
              const SizedBox(height: 12),
              const _WidgetCard(
                label: 'RECOVERY',
                value: '82 · Strong',
                subtext: 'Go hard today',
                gradient: AppGradients.heroDark,
                textColor: Colors.white,
                labelOpacity: 0.7,
              ),
              const SizedBox(height: 12),
              const _WidgetCard(
                label: 'NEXT SESSION',
                value: 'Standard · 26 min',
                subtext: 'Recommended for mornings',
                gradient: AppGradients.btnCold,
                textColor: Colors.white,
                labelOpacity: 0.85,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Add to home screen',
                fullWidth: true,
                marginTop: 0,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Widget added')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({
    required this.label,
    required this.value,
    required this.subtext,
    required this.gradient,
    required this.textColor,
    required this.labelOpacity,
  });

  final String label;
  final String value;
  final String subtext;
  final Gradient gradient;
  final Color textColor;
  final double labelOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A14142D),
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(labelOpacity),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: label == 'NEXT SESSION' ? 20 : 26,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(labelOpacity),
            ),
          ),
        ],
      ),
    );
  }
}
