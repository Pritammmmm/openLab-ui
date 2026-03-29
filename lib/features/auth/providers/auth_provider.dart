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
        state.status == AuthStatus.loading) return;
    _invalidateAllData();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _invalidateAllData() {
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
    state = state.copyWith(status: AuthStatus.loading);
    try {
      _ref.read(dioClientProvider).authInterceptor.resetSessionState();
      final user = await _repository.getCurrentUser();
      print('[AUTH] getCurrentUser returned: ${user?.id}');
      if (user != null) {
        // Reset interceptor in case silent re-auth occurred during getCurrentUser
        _ref.read(dioClientProvider).authInterceptor.resetSessionState();
        print('[AUTH] Calling identifyRevenueCatUser with id: ${user.id}');
        await identifyRevenueCatUser(user.id);
        print('[AUTH] identifyRevenueCatUser completed');
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );

        // Set backend plan so UI can use it as fallback when RC has issues
        _updateBackendPlan(user);

        // Sync subscription with backend in background on every app launch
        _syncSubscriptionInBackground();
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('[AUTH] checkAuthStatus error: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Map the backend subscription plan string to PlanTier and update the provider.
  void _updateBackendPlan(UserModel user) {
    final planStr = user.subscription.plan;
    final tier = switch (planStr) {
      'family' => PlanTier.family,
      'plus' => PlanTier.plus,
      _ => PlanTier.free,
    };
    _ref.read(backendPlanProvider.notifier).state = tier;
  }

  /// Fire-and-forget sync so the backend stays in sync with RevenueCat.
  void _syncSubscriptionInBackground() {
    try {
      final dioClient = _ref.read(dioClientProvider);
      syncSubscriptionWithBackend(dioClient).then((_) {
        // Refresh user data after sync to pick up updated plan
        _repository.getCurrentUser().then((updatedUser) {
          if (updatedUser != null && mounted) {
            state = state.copyWith(user: updatedUser);
            _updateBackendPlan(updatedUser);
          }
        });
      });
    } catch (e) {
      debugPrint('Background subscription sync failed: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      // Reset interceptor so it allows requests again after a prior session expiry
      _ref.read(dioClientProvider).authInterceptor.resetSessionState();
      final authResponse = await _repository.signInWithGoogle();
      await identifyRevenueCatUser(authResponse.user.id);
      _invalidateAllData();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        isNewUser: authResponse.isNewUser,
      );

      // Sync subscription in background after login
      _syncSubscriptionInBackground();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      _ref.read(dioClientProvider).authInterceptor.resetSessionState();
      final authResponse = await _repository.signInWithFacebook();
      await identifyRevenueCatUser(authResponse.user.id);
      _invalidateAllData();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        isNewUser: authResponse.isNewUser,
      );

      _syncSubscriptionInBackground();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      await resetRevenueCatUser();
    } finally {
      _invalidateAllData();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void clearNewUserFlag() {
    state = state.copyWith(isNewUser: false);
  }
}
