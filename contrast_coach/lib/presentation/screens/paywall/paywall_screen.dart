import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionRepository _repo = SubscriptionRepositoryImpl();
  final AnalyticsApi _analytics = AnalyticsApi(FirebaseAnalytics.instance);
  List<Package> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _analytics.trackPaywallViewed();
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
          _analytics.trackSubscriptionStarted(tier.name);
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
      appBar: const ContrastAppBar(title: 'Pro', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('All 10 protocols', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Full recovery score with HRV and sleep', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Health Connect integration', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                    ...(_packages.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppButton(
                            label: p.storeProduct.priceString,
                            onPressed: () => _purchase(p),
                          ),
                        ))),
              if (!_loading && _packages.isEmpty) ...[
                AppButton(label: r'$5.99 / month', onPressed: () {}),
                const SizedBox(height: 8),
                AppButton(label: r'$39.99 / year', onPressed: () {}, variant: AppButtonVariant.secondary),
                const SizedBox(height: 8),
                AppButton(label: r'$89.99 lifetime', onPressed: () {}, variant: AppButtonVariant.tertiary),
              ],
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _restore,
                  child: const Text('Restore purchases'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
