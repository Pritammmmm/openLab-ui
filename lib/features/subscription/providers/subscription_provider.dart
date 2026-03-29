import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
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
  print('[RC] Logging in with userId: $userId');
  final result = await Purchases.logIn(userId);
  print('[RC] LogIn result — created: ${result.created}');
  print('[RC] App user ID: ${result.customerInfo.originalAppUserId}');
  print('[RC] Entitlements after login: ${result.customerInfo.entitlements.all.keys.toList()}');

  // Restore purchases to link any orphaned Google Play purchases to this user
  try {
    final restored = await Purchases.restorePurchases();
    print('[RC] Restore done — entitlements: ${restored.entitlements.all.keys.toList()}');
    for (final entry in restored.entitlements.all.entries) {
      print('[RC]   ${entry.key}: active=${entry.value.isActive}, product=${entry.value.productIdentifier}');
    }
  } catch (e) {
    print('[RC] Restore failed: $e');
  }
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

/// Backend-derived plan, set by AuthNotifier after login/sync.
/// Acts as fallback when RevenueCat has credential issues.
final backendPlanProvider = StateProvider<PlanTier>((ref) => PlanTier.free);

/// Active plan tier — uses RevenueCat as primary, backend user model as fallback.
/// This ensures the UI stays unlocked even if RevenueCat has credential issues.
final activePlanProvider = Provider<PlanTier>((ref) {
  // Primary: RevenueCat entitlements
  final info = ref.watch(customerInfoProvider).valueOrNull;
  if (info != null) {
    if (info.entitlements.all[AppConfig.familyEntitlementId]?.isActive == true) {
      return PlanTier.family;
    }
    if (info.entitlements.all[AppConfig.plusEntitlementId]?.isActive == true) {
      return PlanTier.plus;
    }
  }

  // Fallback: backend-reported plan (set from user model after auth/sync)
  final backendPlan = ref.watch(backendPlanProvider);
  if (backendPlan != PlanTier.free) return backendPlan;

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
/// When a [dioClient] is provided, syncs the purchase with the backend.
Future<bool> purchasePackage(Package package, {DioClient? dioClient}) async {
  try {
    await Purchases.purchase(PurchaseParams.package(package));

    // Sync with backend so it knows about the purchase immediately
    if (dioClient != null) {
      await syncSubscriptionWithBackend(dioClient);
    }

    return true;
  } on PlatformException catch (e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.purchaseCancelledError) {
      return false;
    }
    rethrow;
  }
}

/// Tell the backend to verify our subscription with RevenueCat and update the DB.
/// Fire-and-forget safe — errors are logged but don't break the purchase flow.
Future<void> syncSubscriptionWithBackend(DioClient dioClient) async {
  try {
    await dioClient.post(ApiEndpoints.subscriptionSync, data: {});
    debugPrint('✓ Subscription synced with backend');
  } catch (e) {
    debugPrint('⚠ Subscription sync failed (will retry on next app launch): $e');
  }
}

/// Restore previous purchases (required by Google Play policy).
Future<CustomerInfo> restorePurchases() async {
  return Purchases.restorePurchases();
}
