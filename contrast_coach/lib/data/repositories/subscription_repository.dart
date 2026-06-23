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

  @override
  Future<Result<SubscriptionTier, AppException>> currentTier() async {
    if (!RevenueCatBootstrap.isConfigured) {
      return Err(_notConfiguredError());
    }
    try {
      final info = await Purchases.getCustomerInfo();
      return Ok(_toTier(info));
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
      return Ok(_toTier(info));
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
      return Ok(_toTier(info));
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
    final isPro = info.entitlements.all.containsKey('pro') &&
        (info.entitlements.all['pro']?.isActive ?? false);
    return isPro ? SubscriptionTier.proYearly : SubscriptionTier.free;
  }

  bool _isUserCancellation(PlatformException e) {
    final code = e.code.toUpperCase();
    return code.contains('USER_CANCELLED') ||
        code.contains('PURCHASE_CANCELLED') ||
        e.message?.contains('cancelled') == true;
  }

  AppException _notConfiguredError() {
    return SubscriptionException('RevenueCat is not configured. Please try again later.');
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

extension _StartWithAsync<T> on Stream<T> {
  Stream<T> startWithAsync(Future<T> Function() supplier) async* {
    yield await supplier();
    yield* this;
  }
}
