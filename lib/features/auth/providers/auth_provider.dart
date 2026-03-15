import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../history/providers/history_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../report/providers/report_provider.dart';
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
      final user = await _repository.getCurrentUser();
      if (user != null) {
        await identifyRevenueCatUser(user.id);
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final authResponse = await _repository.signInWithGoogle();
      await identifyRevenueCatUser(authResponse.user.id);
      _invalidateAllData();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        isNewUser: authResponse.isNewUser,
      );
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
