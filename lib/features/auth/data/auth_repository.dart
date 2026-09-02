import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required AuthApi api,
    required SecureStorage storage,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _api = api,
        _storage = storage,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase sign-in failed');
    }

    final firebaseIdToken = await firebaseUser.getIdToken();
    if (firebaseIdToken == null) {
      throw Exception('Failed to get Firebase ID token');
    }

    // Try backend, fall back to Firebase-only if server is unreachable
    try {
      final apiResponse = await _api.signInWithGoogle(firebaseIdToken);
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final authResponse = apiResponse.data!;
      await _storage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Ensure photo URL from Google is available even if backend didn't store it
      if (authResponse.user.photoUrl == null &&
          firebaseUser.photoURL != null) {
        return AuthResponse(
          user: authResponse.user.copyWith(photoUrl: firebaseUser.photoURL),
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          isNewUser: authResponse.isNewUser,
        );
      }

      return authResponse;
    } catch (e) {
      // Fallback: use Firebase user directly when backend is down
      final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;
      final user = UserModel(
        id: firebaseUser.uid,
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL,
        subscription: const SubscriptionInfo(),
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );

      await _storage.saveTokens(
        accessToken: firebaseIdToken,
        refreshToken: firebaseIdToken,
      );

      return AuthResponse(
        user: user,
        accessToken: firebaseIdToken,
        refreshToken: firebaseIdToken,
        isNewUser: isNew,
      );
    }
  }

  // Facebook sign-in — disabled until Facebook App ID is configured
  // Future<AuthResponse> signInWithFacebook() async { ... }

  /// Fetches the current user from the backend. Returns null if the backend
  /// is unreachable — callers should preserve cached data in that case rather
  /// than treating null as "no user."
  Future<UserModel?> getCurrentUser() async {
    final hasTokens = await _storage.hasTokens();
    if (!hasTokens) {
      return _trySilentReauth();
    }

    try {
      final response = await _api.getMe();
      if (response.success && response.data != null) {
        var user = response.data!;
        if (user.photoUrl == null) {
          final firebaseUser = _firebaseAuth.currentUser;
          if (firebaseUser?.photoURL != null) {
            user = user.copyWith(photoUrl: firebaseUser!.photoURL);
          }
        }
        return user;
      }
    } catch (e) {
      debugPrint('[AUTH] getMe failed: $e');
    }

    return _trySilentReauth();
  }

  /// Silently re-authenticate with the backend using the existing Firebase
  /// session. Returns null if the backend is unreachable — never fabricates
  /// a local-only user, because that would erase the real subscription state.
  Future<UserModel?> _trySilentReauth() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) {
        debugPrint('[AUTH] Silent reauth: no ID token available');
        return null;
      }

      final apiResponse = await _api.signInWithGoogle(idToken);
      if (!apiResponse.success || apiResponse.data == null) {
        debugPrint('[AUTH] Silent reauth: backend rejected token');
        return null;
      }

      final authResponse = apiResponse.data!;
      await _storage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      var user = authResponse.user;
      if (user.photoUrl == null && firebaseUser.photoURL != null) {
        user = user.copyWith(photoUrl: firebaseUser.photoURL);
      }
      return user;
    } catch (e) {
      debugPrint('[AUTH] Silent reauth failed (backend unreachable): $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _api.logout(refreshToken);
      }
    } catch (_) {
      // Best effort logout on server
    }

    await _storage.clearTokens();
    await _googleSignIn.signOut();
    // await FacebookAuth.instance.logOut();
    await _firebaseAuth.signOut();
  }

  /// Whether there is an active Firebase user session (regardless of backend).
  bool get hasFirebaseUser => _firebaseAuth.currentUser != null;

  Future<bool> hasValidSession() async {
    return _storage.hasTokens();
  }
}
