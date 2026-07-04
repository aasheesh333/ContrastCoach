import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

/// v4 Help & support — mockup `#help`.
///
/// `.appbar` "Help & support" h2.
/// `.card.list` of 4 FAQ rowlinks: ❄️ How cold should the plunge be?,
///   🌡️ How long in the sauna?, 📊 How is my Recovery Score calculated?,
///   💳 Manage or cancel subscription.
/// `.btn.ghost2` "Contact support".
/// Centered footnote 11 ink3 w700: "ContrastCoach v4.0 · Not a medical device."
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    const faqs = <_Faq>[
      _Faq(emoji: '❄️', title: 'How cold should the plunge be?'),
      _Faq(emoji: '🌡️', title: 'How long in the sauna?'),
      _Faq(emoji: '📊', title: 'How is my Recovery Score calculated?'),
      _Faq(emoji: '💳', title: 'Manage or cancel subscription'),
    ];
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(title: 'Help & support', showBackButton: true),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.lineColor),
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
                  children: [
                    for (var i = 0; i < faqs.length; i++) ...[
                      _FaqRow(faq: faqs[i]),
                      if (i < faqs.length - 1)
                        Container(height: 1, color: ext.lineColor),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Contact support',
                variant: AppButtonVariant.ghost2,
                fullWidth: true,
                marginTop: 0,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support email opened')),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'ContrastCoach v4.0 · Not a medical device.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ext.textFaint,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Faq {
  const _Faq({required this.emoji, required this.title});
  final String emoji;
  final String title;
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({required this.faq});
  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${faq.title} (coming soon)'))),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(faq.emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  faq.title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text('›',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
