import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _onboardingPrefix = 'onboarding_done_';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasCompletedOnboarding(String userId) async {
    final val = await _storage.read(key: '$_onboardingPrefix$userId');
    return val == 'true';
  }

  Future<void> markOnboardingComplete(String userId) async {
    await _storage.write(key: '$_onboardingPrefix$userId', value: 'true');
  }

  Future<void> clearOnboarding(String userId) async {
    await _storage.delete(key: '$_onboardingPrefix$userId');
  }

  // ── Cached user JSON (avoid API call on app resume) ──

  static const _cachedUserKey = 'cached_user';

  Future<void> cacheUser(String userJson) async {
    await _storage.write(key: _cachedUserKey, value: userJson);
  }

  Future<String?> getCachedUser() async {
    return _storage.read(key: _cachedUserKey);
  }

  Future<void> clearCachedUser() async {
    await _storage.delete(key: _cachedUserKey);
  }
}
