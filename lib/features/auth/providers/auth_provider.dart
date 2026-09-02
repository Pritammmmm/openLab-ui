import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../history/providers/history_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../report/providers/report_provider.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../trends/providers/trends_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isNewUser;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isNewUser = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isNewUser,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isNewUser: isNewUser ?? this.isNewUser,
      error: error,
    );
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    // Wire session-expired callback so the interceptor can trigger logout
    _ref.read(sessionExpiredCallbackProvider).onExpired = _onSessionExpired;
    checkAuthStatus();
  }

  void _onSessionExpired() {
    // Skip if already unauthenticated or if checkAuthStatus is in progress
    // (loading state means we're already handling re-auth)
    if (state.status == AuthStatus.unauthenticated ||
        state.status == AuthStatus.loading) {
      return;
    }
    _invalidateAllData();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _invalidateAllData() {
    _ref.invalidate(allProfilesProvider);
    _ref.invalidate(profilesProvider);
    _ref.invalidate(manageProfilesProvider);
    _ref.invalidate(latestReportProvider);
    _ref.invalidate(reportDetailProvider);
    _ref.invalidate(reportStatusProvider);
    _ref.invalidate(trendsDataProvider);
    _ref.invalidate(historyNotifierProvider);
    _ref.read(selectedProfileIndexProvider.notifier).state = 0;
  }

  Future<void> checkAuthStatus() async {
    final storage = _ref.read(secureStorageProvider);

    // 1. Try instant restore from cached user (no API call)
    final hasTokens = await storage.hasTokens();
    if (hasTokens) {
      final cachedJson = await storage.getCachedUser();
      if (cachedJson != null) {
        try {
          final user = UserModel.fromJson(jsonDecode(cachedJson));
          _updateBackendPlan(user);
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
            isNewUser: !user.onboardingCompleted,
          );
          _refreshAuthInBackground();
          return;
        } catch (_) {
          // Cached data corrupt — fall through to API check
        }
      }
    }

    // 2. No cache — do full API check
    state = state.copyWith(status: AuthStatus.loading);
    try {
      _ref.read(dioClientProvider).authInterceptor.resetSessionState();
      final user = await _repository.getCurrentUser();
      if (user != null) {
        _ref.read(dioClientProvider).authInterceptor.resetSessionState();
        await identifyRevenueCatUser(user.id, restore: true);
        _updateBackendPlan(user);
        await _cacheUser(user);

        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isNewUser: !user.onboardingCompleted,
        );

        _syncSubscriptionInBackground();
      } else {
        await storage.clearCachedUser();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('[AUTH] checkAuthStatus error: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Background refresh — verifies token, updates user data, syncs subscription.
  /// If the backend is unreachable (returns null), preserves the current cached
  /// state so a network blip doesn't wipe out subscription data.
  void _refreshAuthInBackground() {
    Future(() async {
      try {
        _ref.read(dioClientProvider).authInterceptor.resetSessionState();
        final user = await _repository.getCurrentUser();
        if (user != null) {
          _ref.read(dioClientProvider).authInterceptor.resetSessionState();
          await identifyRevenueCatUser(user.id);
          _updateBackendPlan(user);
          await _cacheUser(user);
          if (mounted) {
            state = state.copyWith(
              user: user,
              isNewUser: !user.onboardingCompleted,
            );
          }
          _syncSubscriptionInBackground(freshUser: user);
        } else {
          // Backend unreachable — check if we have a Firebase session.
          // If Firebase session is gone, force logout. Otherwise keep cached state.
          final hasFirebaseSession =
              _ref.read(authRepositoryProvider).hasFirebaseUser;
          if (!hasFirebaseSession) {
            await _ref.read(secureStorageProvider).clearCachedUser();
            if (mounted) {
              _invalidateAllData();
              state = const AuthState(status: AuthStatus.unauthenticated);
            }
          } else {
            debugPrint(
                '[AUTH] Background refresh: backend unreachable, keeping cached state');
          }
        }
      } catch (e) {
        debugPrint('[AUTH] Background refresh failed: $e');
      }
    });
  }

  Future<void> _cacheUser(UserModel user) async {
    await _ref.read(secureStorageProvider).cacheUser(jsonEncode(user.toJson()));
  }

  /// Map the backend subscription plan string to PlanTier and update the provider.
  /// Checks expiresAt — if the subscription has expired, treats as free.
  void _updateBackendPlan(UserModel user) {
    final planStr = user.subscription.plan;
    final expiresAt = user.subscription.expiresAt;
    final isExpired = expiresAt != null && expiresAt.isBefore(DateTime.now());

    final tier = isExpired
        ? PlanTier.free
        : switch (planStr) {
            'family' => PlanTier.family,
            'plus' => PlanTier.plus,
            _ => PlanTier.free,
          };
    final previous = _ref.read(backendPlanProvider);
    _ref.read(backendPlanProvider.notifier).state = tier;
    debugPrint(
        '[AUTH] backendPlan updated: $previous → $tier (raw: "$planStr", expired: $isExpired, expiresAt: $expiresAt)');
  }

  /// Fire-and-forget sync so the backend stays in sync with RevenueCat.
  /// Always applies the synced plan (including downgrades on expiration).
  void _syncSubscriptionInBackground({UserModel? freshUser}) {
    try {
      final dioClient = _ref.read(dioClientProvider);

      syncSubscriptionWithBackend(dioClient).then((_) async {
        final updatedUser = freshUser ?? await _repository.getCurrentUser();
        if (updatedUser != null && mounted) {
          debugPrint(
              '[AUTH] Post-sync user plan: "${updatedUser.subscription.plan}" '
              '(isPremium: ${updatedUser.subscription.isPremium}, '
              'expiresAt: ${updatedUser.subscription.expiresAt})');

          state = state.copyWith(user: updatedUser);
          _updateBackendPlan(updatedUser);
          _cacheUser(updatedUser);
        } else {
          debugPrint(
              '[AUTH] Post-sync: backend unreachable, keeping current plan');
        }
      });
    } catch (e) {
      debugPrint('[AUTH] Background subscription sync failed: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      _ref.read(dioClientProvider).authInterceptor.resetSessionState();
      final authResponse = await _repository.signInWithGoogle();
      await identifyRevenueCatUser(authResponse.user.id, restore: true);
      _invalidateAllData();
      _updateBackendPlan(authResponse.user);
      final needsOnboarding = !authResponse.user.onboardingCompleted;
      debugPrint('[AUTH] signInWithGoogle — needsOnboarding: $needsOnboarding');
      await _cacheUser(authResponse.user);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        isNewUser: needsOnboarding,
      );

      _syncSubscriptionInBackground();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  // Facebook sign-in — disabled until Facebook App ID is configured
  // Future<void> signInWithFacebook() async { ... }

  Future<void> logout() async {
    try {
      await _repository.logout();
      await resetRevenueCatUser();
    } finally {
      await _ref.read(secureStorageProvider).clearCachedUser();
      _invalidateAllData();
      _ref.read(backendPlanProvider.notifier).state = PlanTier.free;
      _ref.invalidate(customerInfoProvider);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Called on app resume to refresh subscription state from backend.
  void refreshSubscription() {
    if (state.status != AuthStatus.authenticated) return;
    _syncSubscriptionInBackground();
  }

  void clearNewUserFlag() {
    state = state.copyWith(isNewUser: false);
  }

  Future<void> completeOnboarding() async {
    try {
      final api = _ref.read(authApiProvider);
      final response = await api.completeOnboarding();
      if (response.success && response.data != null) {
        await _cacheUser(response.data!);
        state = state.copyWith(user: response.data!, isNewUser: false);
      } else {
        final updated = state.user?.copyWith(onboardingCompleted: true);
        if (updated != null) await _cacheUser(updated);
        state = state.copyWith(user: updated, isNewUser: false);
      }
    } catch (e) {
      debugPrint('[AUTH] completeOnboarding API failed: $e');
      final updated = state.user?.copyWith(onboardingCompleted: true);
      if (updated != null) await _cacheUser(updated);
      state = state.copyWith(user: updated, isNewUser: false);
    }
  }
}
