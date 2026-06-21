import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionRepository _repo = SubscriptionRepositoryImpl();
  final AnalyticsApi? _analytics = AnalyticsApi.tryCreate();
  List<Package> _packages = [];
  bool _loading = true;
  String? _selectedPeriod = 'yearly';

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
      (_) => setState(() => _loading = false),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchases restored')));
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No previous purchases found')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.heat),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: AppColors.white.withOpacity(0.2),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => context.pop(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(LucideIcons.x, color: AppColors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'UPGRADE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ContrastCoach Pro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),
              // Features
              for (final f in const [
                'All 10 protocols + custom builder',
                'Health Connect & HRV tracking',
                'Unlimited cloud sync',
                'Voice control in any language',
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check, color: AppColors.brandWarm, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Pricing cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _PriceCard(
                      label: 'Monthly',
                      price: r'$5.99',
                      sub: 'per month',
                      isBest: false,
                      selected: _selectedPeriod == 'monthly',
                      onTap: () => setState(() => _selectedPeriod = 'monthly'),
                    ),
                    const SizedBox(height: 12),
                    _PriceCard(
                      label: 'Yearly',
                      price: r'$39.99',
                      sub: r'$3.33/mo · save 44%',
                      isBest: true,
                      selected: _selectedPeriod == 'yearly',
                      onTap: () => setState(() => _selectedPeriod = 'yearly'),
                    ),
                    const SizedBox(height: 12),
                    _PriceCard(
                      label: 'Lifetime',
                      price: r'$89.99',
                      sub: 'one-time',
                      isBest: false,
                      selected: _selectedPeriod == 'lifetime',
                      onTap: () => setState(() => _selectedPeriod = 'lifetime'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppButton(
                  label: 'Continue with ${_capitalize(_selectedPeriod ?? 'yearly')}',
                  onPressed: () {
                    // Find matching package from RevenueCat
                    Package? match;
                    for (final p in _packages) {
                      final id = p.identifier.toLowerCase();
                      if ((_selectedPeriod == 'monthly' && id.contains('month')) ||
                          (_selectedPeriod == 'yearly' && (id.contains('year') || id.contains('annual'))) ||
                          (_selectedPeriod == 'lifetime' && id.contains('lifetime'))) {
                        match = p;
                        break;
                      }
                    }
                    if (match != null) {
                      _purchase(match);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subscription not available in this build.')),
                      );
                    }
                  },
                  variant: AppButtonVariant.primary,
                  fullWidth: true,
                  size: AppButtonSize.large,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _restore,
                child: const Text(
                  'Restore purchases',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => MedicalDisclaimerDialog(onAcknowledge: () => Navigator.of(context).pop()),
                ),
                child: const Text(
                  'Cancel anytime. Not a medical device.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.label,
    required this.price,
    required this.sub,
    required this.isBest,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String price;
  final String sub;
  final bool isBest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isBest ? AppColors.brandWarm : Colors.transparent,
          width: isBest ? 2.5 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.brandWarm : AppColors.midGray,
                    width: 2,
                  ),
                  color: selected ? AppColors.brandWarm : Colors.transparent,
                ),
                child: selected
                    ? const Icon(LucideIcons.check, size: 14, color: AppColors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        if (isBest)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandWarm,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        Text(
                          sub,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: AppColors.midGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
