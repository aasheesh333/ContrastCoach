import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/remote/subscription/revenue_cat_client.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/sheet_container.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// v4 Paywall — modal bottom sheet.
///
/// Mockup `#modal` / `.sheet`:
///   scrim `rgba(8,8,12,.5)` + blur(6),
///   sheet `border-radius: 28 28 44 44`, padding `22 18 28`,
///   slide-up `.45s cubic-bezier(.2,.8,.2,1)`,
///   40×4 grab bar,
///   `🔥 CONTRASTCOACH PRO` pw-badge,
///   `.pw-h` headline "See what actually works for you" (21 w800 ls -.5),
///   `.pw-s` sub "Unlock HRV insights, all protocols, breathwork & cloud backup." (13 ink2 w500),
///   `.trust` row (50k+ / 4.9★ / 92%),
///   3 plans (Monthly / Yearly preselected / Lifetime) with `.save` badge on yearly,
///   6 ✓ feature chips (All protocols / HRV insights / Breathwork / Cloud backup / Custom protocols / Analytics),
///   `.reviews` carousel (2 cards, ★★★★★ gold #FFB020, quotes from Marco / Dana),
///   `.btn` "Start 7-day free trial" heat gradient,
///   `.links` "Restore · Terms · Privacy · Maybe later".
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionRepository _repo = SubscriptionRepositoryImpl()
    ..bindSharedState(SharedSubscriptionState.instance);
  final AnalyticsApi? _analytics = AnalyticsApi.tryCreate();
  List<Package> _packages = const [];
  bool _loading = true;
  String? _error;
  String _selectedPeriod = 'yearly';

  bool get _isUnconfigured => !RevenueCatBootstrap.isConfigured && _error != null;
  bool get _isDevMode => kDebugMode || EnvConfig.isDev;

  String get _unconfiguredTitle => _isDevMode
      ? 'RevenueCat not configured'
      : 'Subscriptions will be available after app store review.';

  String get _unconfiguredBody => _isDevMode
      ? 'Set REVENUECAT_API_KEY via --dart-define to enable subscriptions in development.'
      : 'Please try again later or download from the Play Store.';

  @override
  void initState() {
    super.initState();
    _analytics?.trackPaywallViewed();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final result = await _repo.getOfferings();
    if (!mounted) return;
    result.fold(
      (err) => setState(() {
        _loading = false;
        _error = err.message;
      }),
      (packages) => setState(() {
        _packages = packages;
        _loading = false;
      }),
    );
  }

  Future<void> _purchase(Package package) async {
    setState(() => _loading = true);
    final result = await _repo.purchase(package);
    if (!mounted) return;
    result.fold(
      (err) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
      },
      (tier) {
        if (tier.isPro) {
          _analytics?.trackSubscriptionStarted(tier.name);
          context.pop();
        } else {
          setState(() => _loading = false);
        }
      },
    );
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    final result = await _repo.restore();
    if (!mounted) return;
    result.fold(
      (err) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
      },
      (tier) {
        setState(() => _loading = false);
        if (tier.isPro) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No previous purchases found')),
          );
        }
      },
    );
  }

  void _startTrial() {
    if (_isUnconfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isDevMode
            ? 'RevenueCat not configured. Set the API key to enable subscriptions.'
            : 'Subscriptions will be available after app store review. Please try again later.')),
      );
      return;
    }
    for (final p in _packages) {
      if (_packageIdentifier(p) == _selectedPeriod) {
        _purchase(p);
        return;
      }
    }
    if (_packages.isEmpty && !_loading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscriptions will be available after app store review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _Scrim(onClose: () => context.pop()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
              child: SheetContainer(
                onClose: () => context.pop(),
                child: _PaywallContent(
                  loading: _loading,
                  error: _error,
                  isUnconfigured: _isUnconfigured,
                  unconfiguredTitle: _unconfiguredTitle,
                  unconfiguredBody: _unconfiguredBody,
                  packages: _packages,
                  selectedPeriod: _selectedPeriod,
                  onSelectPeriod: (p) => setState(() => _selectedPeriod = p),
                  onStartTrial: _startTrial,
                  onRestore: _restore,
                  onTerms: () => context.push('/terms'),
                  onPrivacy: () => context.push('/privacy'),
                  onClose: () => context.pop(),
                  packageIdentifier: _packageIdentifier,
                  packageLabel: _packageLabel,
                  packagePrice: _packagePrice,
                  packageSub: _packageSub,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _packageIdentifier(Package pkg) {
    final id = pkg.identifier.toLowerCase();
    if (id.contains('month')) return 'monthly';
    if (id.contains('year') || id.contains('annual')) return 'yearly';
    if (id.contains('lifetime')) return 'lifetime';
    return id;
  }

  String _packageLabel(Package pkg) {
    final id = _packageIdentifier(pkg);
    return switch (id) {
      'monthly' => 'Monthly',
      'yearly' => 'Yearly',
      'lifetime' => 'Lifetime',
      _ => pkg.storeProduct.title,
    };
  }

  String _packagePrice(Package pkg) => pkg.storeProduct.priceString;

  String _packageSub(Package pkg) {
    final id = _packageIdentifier(pkg);
    return switch (id) {
      'monthly' => 'Billed monthly',
      'yearly' => r'$2.50/mo · 7-day free trial',
      'lifetime' => 'One-time',
      _ => '',
    };
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: const Color(0x8008080C),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _PaywallContent extends StatelessWidget {
  const _PaywallContent({
    required this.loading,
    required this.error,
    required this.isUnconfigured,
    required this.unconfiguredTitle,
    required this.unconfiguredBody,
    required this.packages,
    required this.selectedPeriod,
    required this.onSelectPeriod,
    required this.onStartTrial,
    required this.onRestore,
    required this.onTerms,
    required this.onPrivacy,
    required this.onClose,
    required this.packageIdentifier,
    required this.packageLabel,
    required this.packagePrice,
    required this.packageSub,
  });

  final bool loading;
  final String? error;
  final bool isUnconfigured;
  final String unconfiguredTitle;
  final String unconfiguredBody;
  final List<Package> packages;
  final String selectedPeriod;
  final ValueChanged<String> onSelectPeriod;
  final VoidCallback onStartTrial;
  final VoidCallback onRestore;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onClose;
  final String Function(Package) packageIdentifier;
  final String Function(Package) packageLabel;
  final String Function(Package) packagePrice;
  final String Function(Package) packageSub;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PwBadge(),
        const SizedBox(height: 12),
        const Text(
          'See what actually works for you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Unlock HRV insights, all protocols, breathwork & cloud backup.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _TrustRow(),
        const SizedBox(height: 14),
        if (error != null && isUnconfigured)
          _ErrorPlanCard(title: unconfiguredTitle, body: unconfiguredBody)
        else if (packages.isEmpty && !loading)
          _FallbackPlans(
            selectedPeriod: selectedPeriod,
            onSelect: onSelectPeriod,
          )
        else
          for (final pkg in packages)
            _PlanCard(
              label: packageLabel(pkg),
              price: packagePrice(pkg),
              sub: packageSub(pkg),
              saveBadge:
                  packageIdentifier(pkg) == 'yearly' ? 'SAVE 50% · FREE TRIAL' : null,
              selected: packageIdentifier(pkg) == selectedPeriod,
              onTap: () => onSelectPeriod(packageIdentifier(pkg)),
            ),
        if (packages.isEmpty && !loading) const SizedBox(height: 9),
        const SizedBox(height: 12),
        _FeatureChips(),
        const SizedBox(height: 12),
        _ReviewsCarousel(),
        const SizedBox(height: 14),
        AppButton(
          label: loading ? '' : 'Start 7-day free trial',
          fullWidth: true,
          marginTop: 0,
          isLoading: loading,
          onPressed: onStartTrial,
        ),
        const SizedBox(height: 10),
        _LinksRow(onRestore: onRestore, onTerms: onTerms, onPrivacy: onPrivacy, onClose: onClose),
      ],
    );
  }
}

/// `.pw-badge` — `🔥 CONTRASTCOACH PRO`, heat text on #fff2ec bg, 11 w800,
/// padding 5/10, radius 20.
class _PwBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.heat.withOpacity(0.2)
              : const Color(0xFFFFF2EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🔥', style: TextStyle(fontSize: 11)),
            SizedBox(width: 6),
            Text(
              'CONTRASTCOACH PRO',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.heat,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.trust` — bg var(--bg), radius 14, padding 12, three columns.
class _TrustRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : Theme.of(context).colorScheme.surface;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TrustStat(value: '50k+', label: 'athletes', ink: cs.onSurface, sub: cs.onSurfaceVariant),
          _TrustStat(value: '4.9★', label: '12k ratings', ink: cs.onSurface, sub: cs.onSurfaceVariant),
          _TrustStat(value: '92%', label: 'keep the streak', ink: cs.onSurface, sub: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _TrustStat extends StatelessWidget {
  const _TrustStat({
    required this.value,
    required this.label,
    required this.ink,
    required this.sub,
  });
  final String value;
  final String label;
  final Color ink;
  final Color sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: sub,
          ),
        ),
      ],
    );
  }
}

/// `.plan` — 1.5px var(--line) border radius 16, padding 13/15,
/// flex justify-between; `.sel` heat border + heat-tint bg.
/// `.save` badge absolute top:-9 right:14, heat→coral gradient, 10 w800,
/// padding 2/8, radius 8.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.price,
    required this.sub,
    required this.saveBadge,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String price;
  final String sub;
  final String? saveBadge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.heat.withOpacity(0.06) : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.heat : ext.lineColor,
            width: 1.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (saveBadge != null)
              Positioned(
                top: -9,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppGradients.btnPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    saveBadge!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 3 static-fallback plan cards shown when RevenueCat hasn't loaded
/// (matches the mockup demo pricing: Monthly $4.99, Yearly $29.99 preselected
/// with `.save` badge "SAVE 50% · FREE TRIAL", Lifetime $79.99).
class _FallbackPlans extends StatelessWidget {
  const _FallbackPlans({required this.selectedPeriod, required this.onSelect});
  final String selectedPeriod;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanCard(
          label: 'Monthly',
          price: r'$4.99',
          sub: 'Billed monthly',
          saveBadge: null,
          selected: selectedPeriod == 'monthly',
          onTap: () => onSelect('monthly'),
        ),
        _PlanCard(
          label: 'Yearly',
          price: r'$29.99',
          sub: r'$2.50/mo · 7-day free trial',
          saveBadge: 'SAVE 50% · FREE TRIAL',
          selected: selectedPeriod == 'yearly',
          onTap: () => onSelect('yearly'),
        ),
        _PlanCard(
          label: 'Lifetime',
          price: r'$79.99',
          sub: 'One-time',
          saveBadge: null,
          selected: selectedPeriod == 'lifetime',
          onTap: () => onSelect('lifetime'),
        ),
      ],
    );
  }
}

class _ErrorPlanCard extends StatelessWidget {
  const _ErrorPlanCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.heat.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.heat, size: 36),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// `.feat` — flex-wrap, 6 ✓ chips. Each chip 12 w600 ink2, ✓ in ok-green #33C27F.
class _FeatureChips extends StatelessWidget {
  static const _features = [
    'All protocols',
    'HRV insights',
    'Breathwork',
    'Cloud backup',
    'Custom protocols',
    'Analytics',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final f in _features)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✓',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                f,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// `.reviews` — horizontal scroll, 2 `.rev` cards (200px wide, bg var(--bg),
/// radius 14, padding 12). ★★★★★ gold #FFB020 11 w700, quote 12 ink2 w500,
/// attribution 11 w600.
class _ReviewsCarousel extends StatelessWidget {
  static const _reviews = [
    ('★★★★★', '“Finally a recovery app that gets it.”', '— Marco, 🇮🇹'),
    ('★★★★★', '“The HRV score keeps me honest.”', '— Dana, 🇺🇸'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : Theme.of(context).colorScheme.surface;
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _reviews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final r = _reviews[i];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.$1,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFB020),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  r.$2,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r.$3,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// `.links` — centered 11 ink3 w600, "Restore · Terms · Privacy · Maybe later".
class _LinksRow extends StatelessWidget {
  const _LinksRow({
    required this.onRestore,
    required this.onTerms,
    required this.onPrivacy,
    required this.onClose,
  });
  final VoidCallback onRestore;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: cs.onSurfaceVariant,
    );
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          GestureDetector(onTap: onRestore, child: Text('Restore', style: style)),
          Text(' · ', style: style),
          GestureDetector(onTap: onTerms, child: Text('Terms', style: style)),
          Text(' · ', style: style),
          GestureDetector(onTap: onPrivacy, child: Text('Privacy', style: style)),
          Text(' · ', style: style),
          GestureDetector(onTap: onClose, child: Text('Maybe later', style: style)),
        ],
      ),
    );
  }
}
