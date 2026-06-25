import 'dart:async';

import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/remote/subscription/revenue_cat_client.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:developer' as developer;

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  static const String _tag = 'SubscriptionRepository';

  SharedSubscriptionState? _sharedState;

  /// Wires this repository to a shared [SharedSubscriptionState] so any
  /// change to RevenueCat's CustomerInfo (e.g. purchases, restores, expirations)
  /// propagates to every screen reading tier via that notifier.
  void bindSharedState(SharedSubscriptionState state) {
    _sharedState = state;
  }

  @override
  Future<Result<SubscriptionTier, AppException>> currentTier() async {
    if (!RevenueCatBootstrap.isConfigured) {
      return Err(_notConfiguredError());
    }
    try {
      final info = await Purchases.getCustomerInfo();
      final tier = _toTier(info);
      _sharedState?.notify(tier);
      return Ok(tier);
    } on PlatformException catch (e, s) {
      _logError('currentTier', e, s);
      return Err(SubscriptionException('Failed to retrieve subscription tier: ${e.message}'));
    } catch (e, s) {
      _logError('currentTier', e, s);
      return Err(SubscriptionException('Failed to retrieve subscription tier: $e'));
    }
  }

  @override
  Future<Result<List<Package>, AppException>> getOfferings() async {
    if (!RevenueCatBootstrap.isConfigured) {
      return Err(_notConfiguredError());
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        return Err(SubscriptionException('No subscription offerings available.'));
      }
      return Ok(current.availablePackages.toList());
    } on PlatformException catch (e, s) {
      _logError('getOfferings', e, s);
      return Err(SubscriptionException('Failed to load offerings: ${e.message}'));
    } catch (e, s) {
      _logError('getOfferings', e, s);
      return Err(SubscriptionException('Failed to load offerings: $e'));
    }
  }

  @override
  Future<Result<SubscriptionTier, AppException>> purchase(Package package) async {
    if (!RevenueCatBootstrap.isConfigured) {
      return Err(_notConfiguredError());
    }
    try {
      final info = await Purchases.purchasePackage(package);
      final tier = _toTier(info);
      _sharedState?.notify(tier);
      return Ok(tier);
    } on PlatformException catch (e, s) {
      if (_isUserCancellation(e)) {
        return Err(SubscriptionException('Purchase cancelled by user.'));
      }
      _logError('purchase', e, s);
      return Err(SubscriptionException('Purchase failed: ${e.message ?? e.toString()}'));
    } catch (e, s) {
      _logError('purchase', e, s);
      return Err(SubscriptionException('Unexpected error during purchase: $e'));
    }
  }

  @override
  Future<Result<SubscriptionTier, AppException>> restore() async {
    if (!RevenueCatBootstrap.isConfigured) {
      return Err(_notConfiguredError());
    }
    try {
      final info = await Purchases.restorePurchases();
      final tier = _toTier(info);
      _sharedState?.notify(tier);
      return Ok(tier);
    } on PlatformException catch (e, s) {
      _logError('restore', e, s);
      return Err(SubscriptionException('Failed to restore purchases: ${e.message}'));
    } catch (e, s) {
      _logError('restore', e, s);
      return Err(SubscriptionException('Failed to restore purchases: $e'));
    }
  }

  @override
  Stream<SubscriptionTier> watchTier() {
    if (!RevenueCatBootstrap.isConfigured) {
      return Stream.value(SubscriptionTier.free);
    }
    return _customerInfoStream().map(_toTier);
  }

  Stream<CustomerInfo> _customerInfoStream() {
    return Stream.periodic(const Duration(minutes: 5))
        .asyncMap((_) => Purchases.getCustomerInfo())
        .startWithAsync(() => Purchases.getCustomerInfo());
  }

  SubscriptionTier _toTier(CustomerInfo info) {
    final pro = info.entitlements.all['pro'];
    if (pro == null || !pro.isActive) return SubscriptionTier.free;

    final productId = pro.productIdentifier.toLowerCase();
    if (productId.contains('lifetime')) return SubscriptionTier.lifetime;
    if (productId.contains('monthly') || productId.contains('month')) return SubscriptionTier.proMonthly;
    return SubscriptionTier.proYearly;
  }

  /// Public mapping used by [RevenueCatBootstrap]'s CustomerInfo listener.
  /// Kept identical to [_toTier] so listener-driven updates match repository
  /// reads.
  @visibleForTesting
  SubscriptionTier toTier(CustomerInfo info) => _toTier(info);

  bool _isUserCancellation(PlatformException e) {
    final code = e.code.toUpperCase();
    return code.contains('USER_CANCELLED') ||
        code.contains('PURCHASE_CANCELLED') ||
        e.message?.contains('cancelled') == true;
  }

  AppException _notConfiguredError() {
    final detail = RevenueCatBootstrap.initError;
    return SubscriptionException(
      detail ?? 'Subscriptions are not available in this build.',
    );
  }

  void _logError(String operation, Object? error, StackTrace stackTrace) {
    if (kDebugMode) {
      developer.log('Error in $operation: $error', name: _tag, error: error, stackTrace: stackTrace);
    } else {
      FirebaseCrashlytics.instance.recordError(
        error ?? 'Unknown error',
        stackTrace,
        reason: 'SubscriptionRepository.$operation failed',
        fatal: false,
      );
    }
  }
}

/// Process-wide subscription tier notifier.
///
/// Replaces the previous pattern of every screen instantiating its own
/// `SubscriptionRepositoryImpl().currentTier()`. One repository is
/// bound to this notifier at app start; it pushes tier updates whenever
/// a purchase, restore, or expiration occurs. Screens that need tier
/// state should listen to [tier] (`tier.addListener(...)`) rather than
/// calling `currentTier()`.
class SharedSubscriptionState {
  SharedSubscriptionState._();

  static final SharedSubscriptionState instance = SharedSubscriptionState._();

  final ValueNotifier<SubscriptionTier> tier =
      ValueNotifier<SubscriptionTier>(SubscriptionTier.free);

  /// Convenience alias so screens can write `_sharedState.addListener(...)`.
  void addListener(VoidCallback listener) => tier.addListener(listener);

  /// Convenience alias so screens can write `_sharedState.removeListener(...)`.
  void removeListener(VoidCallback listener) => tier.removeListener(listener);

  void notify(SubscriptionTier newTier) {
    if (tier.value == newTier) return;
    tier.value = newTier;
  }
}

extension _StartWithAsync<T> on Stream<T> {
  Stream<T> startWithAsync(Future<T> Function() supplier) async* {
    yield await supplier();
    yield* this;
  }
}
