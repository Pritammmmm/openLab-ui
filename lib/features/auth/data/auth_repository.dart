import 'package:firebase_auth/firebase_auth.dart';
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
    if (authResponse.user.photoUrl == null && firebaseUser.photoURL != null) {
      return AuthResponse(
        user: authResponse.user.copyWith(photoUrl: firebaseUser.photoURL),
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        isNewUser: authResponse.isNewUser,
      );
    }

    return authResponse;
  }

  Future<UserModel?> getCurrentUser() async {
    final hasTokens = await _storage.hasTokens();
    if (!hasTokens) return null;

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
      return null;
    } catch (e) {
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
    await _firebaseAuth.signOut();
  }

  Future<bool> hasValidSession() async {
    return _storage.hasTokens();
  }
}
