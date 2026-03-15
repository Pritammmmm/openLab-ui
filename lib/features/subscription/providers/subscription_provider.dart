import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/app_config.dart';
import '../models/subscription_plan.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SDK Lifecycle
// ─────────────────────────────────────────────────────────────────────────────

/// Call once in main(), before runApp.
Future<void> initRevenueCat() async {
  await Purchases.configure(
    PurchasesConfiguration(AppConfig.revenueCatGoogleApiKey),
  );
}

/// Identify the RevenueCat user after login.
Future<void> identifyRevenueCatUser(String userId) async {
  await Purchases.logIn(userId);
}

/// Reset RevenueCat identity on logout.
Future<void> resetRevenueCatUser() async {
  await Purchases.logOut();
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Customer info that auto-updates on purchase, restore, or renewal.
final customerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  final controller = StreamController<CustomerInfo>();

  // Fetch initial value
  Purchases.getCustomerInfo().then(controller.add).catchError((_) {});

  // Listen for updates
  void listener(CustomerInfo info) => controller.add(info);
  Purchases.addCustomerInfoUpdateListener(listener);

  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });

  return controller.stream;
});

/// Active plan tier derived from RevenueCat entitlements.
final activePlanProvider = Provider<PlanTier>((ref) {
  final info = ref.watch(customerInfoProvider).valueOrNull;
  if (info == null) return PlanTier.free;

  if (info.entitlements.all[AppConfig.familyEntitlementId]?.isActive == true) {
    return PlanTier.family;
  }
  if (info.entitlements.all[AppConfig.plusEntitlementId]?.isActive == true) {
    return PlanTier.plus;
  }
  return PlanTier.free;
});

/// Fetches available offerings (products + prices) from Google Play via RevenueCat.
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  try {
    final offerings = await Purchases.getOfferings();
    return offerings;
  } catch (_) {
    return null;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Purchase Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Find the right package for a given plan tier and billing period.
Package? findPackage(List<Package> packages, PlanTier tier, bool isAnnual) {
  final id = _packageId(tier, isAnnual);
  if (id == null) return null;
  try {
    return packages.firstWhere((p) => p.identifier == id);
  } catch (_) {
    return null;
  }
}

String? _packageId(PlanTier tier, bool isAnnual) {
  return switch (tier) {
    PlanTier.free => null,
    PlanTier.plus =>
      isAnnual ? AppConfig.plusAnnualId : AppConfig.plusMonthlyId,
    PlanTier.family =>
      isAnnual ? AppConfig.familyAnnualId : AppConfig.familyMonthlyId,
  };
}

/// Execute a purchase. Returns true on success, false on user cancel.
/// Throws on other errors.
Future<bool> purchasePackage(Package package) async {
  try {
    await Purchases.purchase(PurchaseParams.package(package));
    return true;
  } on PlatformException catch (e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.purchaseCancelledError) {
      return false;
    }
    rethrow;
  }
}

/// Restore previous purchases (required by Google Play policy).
Future<CustomerInfo> restorePurchases() async {
  return Purchases.restorePurchases();
}
