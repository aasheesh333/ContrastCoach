import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionRepository {
  Future<Result<SubscriptionTier, AppException>> currentTier();
  Future<Result<List<Package>, AppException>> getOfferings();
  Future<Result<SubscriptionTier, AppException>> purchase(Package package);
  Future<Result<SubscriptionTier, AppException>> restore();
  Stream<SubscriptionTier> watchTier();
}
