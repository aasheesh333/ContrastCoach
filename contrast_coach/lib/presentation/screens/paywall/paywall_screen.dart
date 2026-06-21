import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget { const PaywallScreen({super.key}); @override State<PaywallScreen> createState() => _PaywallScreenState(); }

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionRepository _repo = SubscriptionRepositoryImpl();
  final AnalyticsApi? _analytics = AnalyticsApi.tryCreate();
  List<Package> _packages = [];
  bool _loading = true;
  @override void initState() { super.initState(); _analytics?.trackPaywallViewed(); _loadOfferings(); }

  Future<void> _loadOfferings() async {
    final result = await _repo.getOfferings();
    if (!mounted) return;
    result.fold((_) => setState(() => _loading = false), (packages) => setState(() { _packages = packages; _loading = false; }));
  }

  Future<void> _purchase(Package package) async {
    setState(() => _loading = true);
    final result = await _repo.purchase(package);
    if (!mounted) return;
    result.fold((_) => setState(() => _loading = false), (_) => context.go('/home'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
      Container(width: double.infinity, padding: EdgeInsets.fromLTRB(AppSpacing.adaptiveX(context), 32, AppSpacing.adaptiveX(context), AppSpacing.xxxl), decoration: BoxDecoration(gradient: AppGradients.heat, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32))), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(LucideIcons.x, color: Colors.white), onPressed: () => context.pop()),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999)), child: Text('PRO', style: cs.textTheme.labelSmall?.copyWith(color: Colors.white))),
        ]),
        const SizedBox(height: AppSpacing.lg),
        const Icon(LucideIcons.crown, color: Colors.white, size: 48),
        const SizedBox(height: AppSpacing.lg),
        Text('Go Pro', style: cs.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        Text('Unlock everything. Cancel anytime.', style: cs.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: AppSpacing.xl),
        Row(children: List.generate(3, (i) => Expanded(child: Column(children: [
          Icon([LucideIcons.infinity, LucideIcons.barChart3, LucideIcons.messageSquare][i], color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(['All protocols', 'Deep insights', 'Voice coach'][i], textAlign: TextAlign.center, style: cs.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500)),
        ])))),
      ])),
      Expanded(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(AppSpacing.adaptiveX(context), AppSpacing.xxl, AppSpacing.adaptiveX(context), AppSpacing.adaptiveBottom(context)), child: Column(children: _packages.where((p) => p.identifier == 'yearly' || p.identifier == 'monthly').map((p) {
        final isBest = p.identifier == 'yearly';
        return Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Material(color: isBest ? cs.primary : cs.surface, borderRadius: BorderRadius.circular(20), child: InkWell(onTap: _loading ? null : () => _purchase(p), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(AppSpacing.xl), decoration: BoxDecoration(border: isBest ? null : Border.all(color: cs.outline.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)), child: Column(children: [
          if (isBest) Container(margin: const EdgeInsets.only(bottom: AppSpacing.sm), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999)), child: Text('BEST VALUE', style: cs.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.identifier == 'yearly' ? 'Yearly' : 'Monthly', style: cs.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isBest ? Colors.white : cs.onSurface)),
              Text(p.identifier == 'yearly' ? 'per year' : 'per month', style: cs.textTheme.bodySmall?.copyWith(color: isBest ? Colors.white.withOpacity(0.7) : cs.onSurfaceVariant)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(p.storeProduct.priceString, style: cs.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: isBest ? Colors.white : cs.onSurface)),
              if (p.identifier == 'yearly') Text('Save 40% vs monthly', style: cs.textTheme.bodySmall?.copyWith(color: isBest ? Colors.white.withOpacity(0.7) : cs.onSurfaceVariant)),
            ]),
          ]),
        ])))));
      }).toList()))),
    ]))));
  }
}
