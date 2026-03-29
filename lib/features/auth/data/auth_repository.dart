import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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

  Future<AuthResponse> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.cancelled) {
      throw Exception('Facebook sign-in was cancelled');
    }
    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw Exception(result.message ?? 'Facebook sign-in failed');
    }

    final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);

    final UserCredential userCredential;
    try {
      userCredential =
          await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // If an account with the same email already exists under a different
      // provider (e.g. Google), surface a clear message instead of a crash.
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          'An account already exists with this email. '
          'Please sign in with Google instead.',
        );
      }
      rethrow;
    }

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase sign-in failed');
    }

    final firebaseIdToken = await firebaseUser.getIdToken();
    if (firebaseIdToken == null) {
      throw Exception('Failed to get Firebase ID token');
    }

    // Backend receives the same Firebase ID token regardless of provider
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

  Future<UserModel?> getCurrentUser() async {
    final hasTokens = await _storage.hasTokens();
    if (!hasTokens) {
      // No tokens — try silent re-auth with existing Firebase session
      return _trySilentReauth();
    }

    try {
      final response = await _api.getMe();
      if (response.success && response.data != null) {
        var user = response.data!;
        // Fill photo URL from Firebase if backend didn't return it
        if (user.photoUrl == null) {
          final firebaseUser = _firebaseAuth.currentUser;
          if (firebaseUser?.photoURL != null) {
            user = user.copyWith(photoUrl: firebaseUser!.photoURL);
          }
        }
        return user;
      }
    } catch (_) {
      // Backend rejected tokens or unreachable — try silent re-auth
    }

    return _trySilentReauth();
  }

  /// Silently re-authenticate with the backend using the existing Firebase session.
  /// Falls back to Firebase-only user if the backend is truly unreachable.
  Future<UserModel?> _trySilentReauth() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) return _firebaseFallbackUser(firebaseUser);

      final apiResponse = await _api.signInWithGoogle(idToken);
      if (!apiResponse.success || apiResponse.data == null) {
        return _firebaseFallbackUser(firebaseUser);
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
    } catch (_) {
      // Backend truly down — return Firebase-only user as last resort
      return _firebaseFallbackUser(firebaseUser);
    }
  }

  UserModel _firebaseFallbackUser(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      firebaseUid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      subscription: const SubscriptionInfo(),
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
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
    await FacebookAuth.instance.logOut();
    await _firebaseAuth.signOut();
  }

  Future<bool> hasValidSession() async {
    return _storage.hasTokens();
  }
}
