import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/health_sync_service.dart';
import 'health_providers.dart';

const _keyGoogleFitEnabled = 'health_sync_google_fit';
const _keySamsungHealthEnabled = 'health_sync_samsung_health';

final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService(ref.watch(healthDatabaseProvider));
});

final healthSyncProvider =
    AsyncNotifierProvider<HealthSyncNotifier, HealthSyncState>(
        HealthSyncNotifier.new);

// ── Toggle result — the UI reacts to this ──

enum ConnectOutcome {
  connected,
  disconnected,
  permissionDenied,
  healthConnectMissing,
  healthConnectNotReady,
  failed,
}

// ── Sync state ──

enum SyncStatus { idle, syncing, success, failed }

class HealthSyncState {
  final bool googleFitEnabled;
  final bool samsungHealthEnabled;
  final SyncStatus syncStatus;
  final DateTime? lastSyncAt;
  final int lastSyncCount;
  final int lastFetchedCount;
  final Map<String, int> lastSyncPerType;
  final String? lastError;
  final SyncErrorType? lastErrorType;
  final bool healthConnectAvailable;

  const HealthSyncState({
    this.googleFitEnabled = false,
    this.samsungHealthEnabled = false,
    this.syncStatus = SyncStatus.idle,
    this.lastSyncAt,
    this.lastSyncCount = 0,
    this.lastFetchedCount = 0,
    this.lastSyncPerType = const {},
    this.lastError,
    this.lastErrorType,
    this.healthConnectAvailable = false,
  });

  bool get anyEnabled => googleFitEnabled || samsungHealthEnabled;
  bool get isSyncing => syncStatus == SyncStatus.syncing;

  HealthSyncState copyWith({
    bool? googleFitEnabled,
    bool? samsungHealthEnabled,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
    int? lastSyncCount,
    int? lastFetchedCount,
    Map<String, int>? lastSyncPerType,
    String? lastError,
    SyncErrorType? lastErrorType,
    bool? healthConnectAvailable,
    bool clearError = false,
  }) {
    return HealthSyncState(
      googleFitEnabled: googleFitEnabled ?? this.googleFitEnabled,
      samsungHealthEnabled: samsungHealthEnabled ?? this.samsungHealthEnabled,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncCount: lastSyncCount ?? this.lastSyncCount,
      lastFetchedCount: lastFetchedCount ?? this.lastFetchedCount,
      lastSyncPerType: lastSyncPerType ?? this.lastSyncPerType,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastErrorType: clearError ? null : (lastErrorType ?? this.lastErrorType),
      healthConnectAvailable:
          healthConnectAvailable ?? this.healthConnectAvailable,
    );
  }
}

class HealthSyncNotifier extends AsyncNotifier<HealthSyncState> {
  @override
  Future<HealthSyncState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final service = ref.watch(healthSyncServiceProvider);

    final googleFit = prefs.getBool(_keyGoogleFitEnabled) ?? false;
    final samsungHealth = prefs.getBool(_keySamsungHealthEnabled) ?? false;
    final available = await service.isHealthConnectAvailable();

    debugPrint('[HealthSync] build() — gFit=$googleFit, samsung=$samsungHealth, hcAvailable=$available');

    final db = ref.watch(healthDatabaseProvider);
    final meta = await db.getSyncMeta('health_connect', 'all');

    final initial = HealthSyncState(
      googleFitEnabled: googleFit && available,
      samsungHealthEnabled: samsungHealth && available,
      healthConnectAvailable: available,
      lastSyncAt: meta?.lastSyncAt,
      lastError: meta?.lastError,
    );

    if (initial.anyEnabled) {
      Future.delayed(Duration.zero, () => syncNow());
    }

    return initial;
  }

  // ── Toggle a platform on/off ──

  Future<ConnectOutcome> toggleGoogleFit(bool enabled) => _toggle(
        enabled: enabled,
        prefKey: _keyGoogleFitEnabled,
        apply: (s, v) => s.copyWith(googleFitEnabled: v, clearError: true),
      );

  Future<ConnectOutcome> toggleSamsungHealth(bool enabled) => _toggle(
        enabled: enabled,
        prefKey: _keySamsungHealthEnabled,
        apply: (s, v) => s.copyWith(samsungHealthEnabled: v, clearError: true),
      );

  Future<ConnectOutcome> _toggle({
    required bool enabled,
    required String prefKey,
    required HealthSyncState Function(HealthSyncState s, bool v) apply,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return ConnectOutcome.failed;

    // ── Turning off is always safe ──
    if (!enabled) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, false);
      state = AsyncData(apply(current, false));
      return ConnectOutcome.disconnected;
    }

    // ── Turning on: check HC availability ──
    final service = ref.read(healthSyncServiceProvider);
    final hcStatus = await service.getHealthConnectStatus();

    if (hcStatus == null) {
      return ConnectOutcome.healthConnectMissing;
    }

    if (hcStatus == HealthConnectSdkStatus.sdkUnavailable) {
      return ConnectOutcome.healthConnectMissing;
    }

    if (hcStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
      return ConnectOutcome.healthConnectNotReady;
    }

    if (hcStatus != HealthConnectSdkStatus.sdkAvailable) {
      return ConnectOutcome.healthConnectMissing;
    }

    // ── Request permissions — opens Health Connect dialog,
    //    then verifies the actual grant state ──
    try {
      final granted = await service.requestAndVerifyPermissions();
      if (!granted) return ConnectOutcome.permissionDenied;
    } catch (e) {
      debugPrint('[HealthSync] Permission error: $e');
      return ConnectOutcome.failed;
    }

    // ── Persist & update state ──
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);
    state = AsyncData(apply(
      current.copyWith(healthConnectAvailable: true),
      true,
    ));

    // ── Kick off sync in background ──
    syncNow();

    return ConnectOutcome.connected;
  }

  // ── Manual sync ──

  Future<void> syncNow() async {
    final current = state.valueOrNull;
    debugPrint('[HealthSync] syncNow called — state=${current != null ? 'loaded' : 'null'}, syncing=${current?.isSyncing}');
    if (current == null || current.isSyncing) return;

    state = AsyncData(current.copyWith(
      syncStatus: SyncStatus.syncing,
      clearError: true,
    ));

    final service = ref.read(healthSyncServiceProvider);
    final result = await service.syncAll();

    final latest = state.valueOrNull ?? current;

    if (result.isSuccess) {
      state = AsyncData(latest.copyWith(
        syncStatus: SyncStatus.success,
        lastSyncAt: DateTime.now(),
        lastSyncCount: result.syncedCount,
        lastFetchedCount: result.fetchedCount,
        lastSyncPerType: result.perType,
        clearError: true,
      ));
    } else {
      state = AsyncData(latest.copyWith(
        syncStatus: SyncStatus.failed,
        lastError: result.errorDetail,
        lastErrorType: result.errorType,
      ));

      // If permissions were revoked mid-sync, disable toggles
      if (result.errorType == SyncErrorType.permissionDenied) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyGoogleFitEnabled, false);
        await prefs.setBool(_keySamsungHealthEnabled, false);
        final s = state.valueOrNull ?? latest;
        state = AsyncData(s.copyWith(
          googleFitEnabled: false,
          samsungHealthEnabled: false,
        ));
      }
    }
  }

  // ── Auto-sync on app resume ──

  Future<void> autoSyncIfEnabled() async {
    final current = state.valueOrNull;
    debugPrint('[HealthSync] autoSyncIfEnabled — state=${current != null ? 'loaded' : 'null'}, enabled=${current?.anyEnabled}');
    if (current == null || !current.anyEnabled) return;

    // Don't check permissions here — hasPermissions() is unreliable on Android
    // and was silently disabling toggles. Let syncNow() handle permission
    // verification via the robust 3-step check in syncAll().
    await syncNow();
  }
}
