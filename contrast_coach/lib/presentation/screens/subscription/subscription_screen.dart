import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 Subscription — mockup `#sub`.
///
/// `.appbar` "Subscription" h2.
/// `.card` "Current plan · Free" + "3 protocols · basic score · local only".
/// `.sec-t` "Upgrade".
/// 3 `.plan` rows (Yearly preselected with `.save` badge, Monthly, Lifetime),
///   each: title + sub + price -> tap to select.
/// `.btn` "Start free trial".
/// `.btn.ghost2` "Restore purchases".
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selected = 'yearly';

  static const _plans = <_Plan>[
    _Plan(
      id: 'yearly',
      title: 'Yearly',
      sub: r'$2.50/mo · 7-day free trial',
      price: r'$29.99',
      save: 'SAVE 50% · FREE TRIAL',
    ),
    _Plan(
      id: 'monthly',
      title: 'Monthly',
      sub: 'Billed monthly',
      price: r'$4.99',
    ),
    _Plan(
      id: 'lifetime',
      title: 'Lifetime',
      sub: 'One-time',
      price: r'$79.99',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;

    final ink = cs.onSurface;
    final ink2Color = cs.onSurfaceVariant;
    final lineColor = ext.lineColor;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar:
          const ContrastAppBar(title: 'Subscription', showBackButton: true),
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
                padding: const EdgeInsets.all(20),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Current plan · Free',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '3 protocols · basic score · local only',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ext.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 0, 2, 12),
                child: Text(
                  'Upgrade',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              for (final p in _plans) ...[
                _PlanCard(
                  plan: p,
                  selected: _selected == p.id,
                  ink: ink,
                  ink2: ink2Color,
                  line: lineColor,
                  surface: cs.surface,
                  onTap: () => setState(() => _selected = p.id),
                ),
                if (p != _plans.last) const SizedBox(height: 10),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: 'Start free trial',
                fullWidth: true,
                marginTop: 0,
                onPressed: () => context.push('/paywall'),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Restore purchases',
                variant: AppButtonVariant.ghost2,
                fullWidth: true,
                marginTop: 0,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchases restored')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Plan {
  const _Plan({
    required this.id,
    required this.title,
    required this.sub,
    required this.price,
    this.save,
  });
  final String id;
  final String title;
  final String sub;
  final String price;
  final String? save;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.ink,
    required this.ink2,
    required this.line,
    required this.surface,
    required this.onTap,
  });
  final _Plan plan;
  final bool selected;
  final Color ink;
  final Color ink2;
  final Color line;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final heat = selected ? const Color(0xFFFF6B35) : line;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: heat, width: selected ? 1.5 : 1),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33FF6B35),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                    spreadRadius: -10,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (plan.save != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.save!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                  top: plan.save != null ? 22 : 6, bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plan.title,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.sub,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    plan.price,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
