import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Mutable holder so the callback can be set after auth providers initialize,
/// without triggering a rebuild of DioClient.
class SessionExpiredCallback {
  void Function() onExpired = () {};
  void call() => onExpired();
}

final sessionExpiredCallbackProvider =
    Provider<SessionExpiredCallback>((ref) => SessionExpiredCallback());

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final connectivity = ref.watch(connectivityProvider);
  final sessionCallback = ref.watch(sessionExpiredCallbackProvider);
  return DioClient(
    storage: storage,
    connectivity: connectivity,
    onSessionExpired: sessionCallback.call,
  );
});
