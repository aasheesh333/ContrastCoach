import 'dart:async';

import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl();

  SubscriptionTier _tierFromCustomerInfo(CustomerInfo info) {
    final entitlements = info.entitlements.all;
    if (entitlements['pro']?.isActive == true) {
      final productId = entitlements['pro']!.productIdentifier;
      if (productId.contains('lifetime')) return SubscriptionTier.lifetime;
      if (productId.contains('yearly') || productId.contains('annual')) {
        return SubscriptionTier.proYearly;
      }
      return SubscriptionTier.proMonthly;
    }
    return SubscriptionTier.free;
  }

  @override
  Future<Result<SubscriptionTier, AppException>> currentTier() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return Ok(_tierFromCustomerInfo(info));
    } catch (e) {
      return Err(SubscriptionException('Failed to read subscription state', cause: e));
    }
  }

  @override
  Future<Result<List<Package>, AppException>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const Ok([]);
      return Ok(current.availablePackages);
    } catch (e) {
      return Err(SubscriptionException('Failed to read offerings', cause: e));
    }
  }

  @override
  Future<Result<SubscriptionTier, AppException>> purchase(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return Ok(_tierFromCustomerInfo(customerInfo));
    } catch (e) {
      return Err(SubscriptionException('Purchase failed', cause: e));
    }
  }

  @override
  Future<Result<SubscriptionTier, AppException>> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      return Ok(_tierFromCustomerInfo(info));
    } catch (e) {
      return Err(SubscriptionException('Restore failed', cause: e));
    }
  }

  @override
  Stream<SubscriptionTier> watchTier() {
    final controller = StreamController<SubscriptionTier>();
    void listener(CustomerInfo info) => controller.add(_tierFromCustomerInfo(info));
    Purchases.addCustomerInfoUpdateListener(listener);
    controller.onCancel = () => Purchases.removeCustomerInfoUpdateListener(listener);
    return controller.stream;
  }
}
