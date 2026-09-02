import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'health_database.dart';

enum SyncErrorType { permissionDenied, healthConnectUnavailable, noData, network, unknown }

class SyncResult {
  final int syncedCount;
  final int fetchedCount;
  final Map<String, int> perType;
  final SyncErrorType? errorType;
  final String? errorDetail;

  const SyncResult({
    required this.syncedCount,
    this.fetchedCount = 0,
    this.perType = const {},
    this.errorType,
    this.errorDetail,
  });

  bool get isSuccess => errorType == null;
  bool get hasData => syncedCount > 0;
}

class HealthSyncService {
  final HealthDatabase _db;
  final Health _health = Health();
  bool _configured = false;

  HealthSyncService(this._db);

  static const _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_TEMPERATURE,
  ];

  static final _readPermissions =
      List.filled(_readTypes.length, HealthDataAccess.READ);

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  // ── Availability ──

  Future<bool> isHealthConnectAvailable() async {
    try {
      final status = await _health.getHealthConnectSdkStatus();
      debugPrint('[HealthSync] Health Connect SDK status: $status');
      return status == HealthConnectSdkStatus.sdkAvailable ||
          status == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired;
    } catch (e) {
      debugPrint('[HealthSync] HC availability check failed: $e');
      return false;
    }
  }

  Future<HealthConnectSdkStatus?> getHealthConnectStatus() async {
    try {
      return await _health.getHealthConnectSdkStatus();
    } catch (_) {
      return null;
    }
  }

  // ── Permissions ──

  Future<bool> requestAndVerifyPermissions() async {
    try {
      await _ensureConfigured();
      await _health.requestAuthorization(
        _readTypes,
        permissions: _readPermissions,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      final granted = await hasPermissions();
      if (granted) return true;
      return await _testFetch();
    } catch (e) {
      debugPrint('[HealthSync] Permission request failed: $e');
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      await _ensureConfigured();
      final result = await _health.hasPermissions(
        _readTypes,
        permissions: _readPermissions,
      );
      debugPrint('[HealthSync] hasPermissions=$result');
      return result ?? false;
    } catch (e) {
      debugPrint('[HealthSync] hasPermissions error: $e');
      return false;
    }
  }

  Future<bool> _testFetch() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: yesterday,
        endTime: now,
      );
      debugPrint('[HealthSync] Test fetch: ${data.length} points — OK');
      return true;
    } catch (e) {
      debugPrint('[HealthSync] Test fetch failed: $e');
      return false;
    }
  }

  // ── Main sync ──

  Future<SyncResult> syncAll() async {
    try {
      debugPrint('[HealthSync] ── syncAll START ──');
      await _ensureConfigured();

      final available = await isHealthConnectAvailable();
      debugPrint('[HealthSync] Health Connect available: $available');
      if (!available) {
        return const SyncResult(
          syncedCount: 0,
          errorType: SyncErrorType.healthConnectUnavailable,
          errorDetail: 'Health Connect is not available on this device.',
        );
      }

      final permResult = await hasPermissions();
      debugPrint('[HealthSync] hasPermissions: $permResult');
      final hasPerms = permResult || await _testFetch();
      debugPrint('[HealthSync] Final permission check: $hasPerms');
      if (!hasPerms) {
        return const SyncResult(
          syncedCount: 0,
          errorType: SyncErrorType.permissionDenied,
          errorDetail: 'Health data permissions have not been granted.',
        );
      }

      final now = DateTime.now();
      final syncStart = await _getSyncStartTime();

      debugPrint('[HealthSync] Fetching data from $syncStart to $now (${now.difference(syncStart).inDays} days)');

      final dataPoints = await _health.getHealthDataFromTypes(
        types: _readTypes,
        startTime: syncStart,
        endTime: now,
      );

      debugPrint('[HealthSync] Raw data points from HC: ${dataPoints.length}');

      final unique = _health.removeDuplicates(dataPoints);

      final Map<String, int> fetched = {};
      for (final p in unique) {
        final key = p.type.name;
        fetched[key] = (fetched[key] ?? 0) + 1;
      }
      debugPrint('[HealthSync] Fetched ${unique.length} unique points: $fetched');

      if (unique.isEmpty) {
        // Don't advance the sync window if nothing was found —
        // user might just not have recorded data yet
        return const SyncResult(syncedCount: 0, fetchedCount: 0);
      }

      final Map<String, int> written = {};
      int n;

      n = await _syncSteps(unique);
      if (n > 0) written['Steps'] = n;

      n = await _syncHeartRate(unique);
      if (n > 0) written['Heart Rate'] = n;

      n = await _syncWeight(unique);
      if (n > 0) written['Weight'] = n;

      n = await _syncBloodPressure(unique);
      if (n > 0) written['Blood Pressure'] = n;

      n = await _syncBloodGlucose(unique);
      if (n > 0) written['Blood Sugar'] = n;

      n = await _syncSleep(unique);
      if (n > 0) written['Sleep'] = n;

      n = await _syncBloodOxygen(unique);
      if (n > 0) written['SpO₂'] = n;

      n = await _syncBodyTemperature(unique);
      if (n > 0) written['Temperature'] = n;

      final total = written.values.fold(0, (a, b) => a + b);

      // Only advance sync window if we actually wrote something
      if (total > 0) {
        await _saveSyncMeta(now, null);
      }

      debugPrint('[HealthSync] Written $total: $written');

      return SyncResult(
        syncedCount: total,
        fetchedCount: unique.length,
        perType: written,
      );
    } catch (e, stack) {
      debugPrint('[HealthSync] Sync failed: $e\n$stack');
      final errorType = _classifyError(e);
      await _saveSyncMeta(null, e.toString());
      return SyncResult(
        syncedCount: 0,
        errorType: errorType,
        errorDetail: e.toString(),
      );
    }
  }

  SyncErrorType _classifyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('permission')) return SyncErrorType.permissionDenied;
    if (msg.contains('health connect')) return SyncErrorType.healthConnectUnavailable;
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
      return SyncErrorType.network;
    }
    return SyncErrorType.unknown;
  }

  Future<DateTime> _getSyncStartTime() async {
    final meta = await _db.getSyncMeta('health_connect', 'all');
    final now = DateTime.now();
    final minWindow = now.subtract(const Duration(days: 7));
    if (meta?.lastSyncAt != null) {
      // Always go back at least 7 days to catch data Samsung Health
      // may have written to Health Connect after our last sync
      return meta!.lastSyncAt!.isBefore(minWindow)
          ? meta.lastSyncAt!
          : minWindow;
    }
    return now.subtract(const Duration(days: 30));
  }

  Future<void> _saveSyncMeta(DateTime? syncTime, String? error) async {
    await _db.upsertSyncMeta(SyncMetadataCompanion(
      platform: const Value('health_connect'),
      dataType: const Value('all'),
      lastSyncAt: Value(syncTime),
      lastError: Value(error),
      enabled: const Value(true),
    ));
  }

  // ── Steps → DailyLogs ──

  Future<int> _syncSteps(List<HealthDataPoint> data) async {
    final points = data.where((d) => d.type == HealthDataType.STEPS).toList();
    debugPrint('[HealthSync] Steps: ${points.length} raw points');
    if (points.isEmpty) return 0;

    final Map<String, int> daily = {};
    for (final p in points) {
      final key = DateFormat('yyyy-MM-dd').format(p.dateFrom);
      final val = (p.value as NumericHealthValue).numericValue.toInt();
      daily[key] = (daily[key] ?? 0) + val;
    }

    debugPrint('[HealthSync] Steps aggregated by day: $daily');

    int count = 0;
    for (final e in daily.entries) {
      final existing = await _db.getDailyLog(e.key);
      final existingSteps = existing?.steps ?? 0;
      debugPrint('[HealthSync] Steps ${e.key}: synced=${e.value} existing=$existingSteps');
      if (e.value > existingSteps) {
        await _db.upsertDailyLog(DailyLogsCompanion(
          dateKey: Value(e.key),
          steps: Value(e.value),
          source: const Value('health_connect'),
          updatedAt: Value(DateTime.now()),
        ));
        count++;
      }
    }
    debugPrint('[HealthSync] Steps: wrote $count day(s)');
    return count;
  }

  // ── Sleep → DailyLogs ──

  Future<int> _syncSleep(List<HealthDataPoint> data) async {
    final points =
        data.where((d) => d.type == HealthDataType.SLEEP_ASLEEP).toList();
    if (points.isEmpty) return 0;

    final Map<String, int> daily = {};
    for (final p in points) {
      final key = DateFormat('yyyy-MM-dd').format(p.dateFrom);
      final mins = p.dateTo.difference(p.dateFrom).inMinutes;
      daily[key] = (daily[key] ?? 0) + mins;
    }

    int count = 0;
    for (final e in daily.entries) {
      final existing = await _db.getDailyLog(e.key);
      if (e.value > (existing?.sleepMinutes ?? 0)) {
        await _db.upsertDailyLog(DailyLogsCompanion(
          dateKey: Value(e.key),
          sleepMinutes: Value(e.value),
          source: const Value('health_connect'),
          updatedAt: Value(DateTime.now()),
        ));
        count++;
      }
    }
    return count;
  }

  // ── Blood Pressure (systolic + diastolic paired) ──

  Future<int> _syncBloodPressure(List<HealthDataPoint> data) async {
    final systolic = data
        .where((d) => d.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC)
        .toList();
    final diastolic = data
        .where((d) => d.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC)
        .toList();
    if (systolic.isEmpty) return 0;

    int count = 0;
    for (final sys in systolic) {
      final sysVal = (sys.value as NumericHealthValue).numericValue.toDouble();
      final externalId = 'hc_bp_${sys.dateFrom.millisecondsSinceEpoch}';
      if (await _db.getMetricByExternalId(externalId) != null) continue;

      double? diaVal;
      for (final dia in diastolic) {
        if (sys.dateFrom.difference(dia.dateFrom).inMinutes.abs() < 5) {
          diaVal = (dia.value as NumericHealthValue).numericValue.toDouble();
          break;
        }
      }

      await _db.insertMetric(HealthMetricsCompanion(
        type: const Value('bloodPressure'),
        value: Value(sysVal),
        value2: Value(diaVal),
        unit: const Value('mmHg'),
        recordedAt: Value(sys.dateFrom),
        source: const Value('health_connect'),
        externalId: Value(externalId),
        createdAt: Value(DateTime.now()),
      ));
      count++;
    }
    return count;
  }

  // ── Generic numeric metrics ──

  Future<int> _syncHeartRate(List<HealthDataPoint> data) =>
      _syncNumeric(data, HealthDataType.HEART_RATE, 'heartRate', 'bpm');

  Future<int> _syncWeight(List<HealthDataPoint> data) =>
      _syncNumeric(data, HealthDataType.WEIGHT, 'weight', 'kg');

  Future<int> _syncBloodGlucose(List<HealthDataPoint> data) =>
      _syncNumeric(data, HealthDataType.BLOOD_GLUCOSE, 'bloodSugar', 'mg/dL');

  Future<int> _syncBloodOxygen(List<HealthDataPoint> data) =>
      _syncNumeric(data, HealthDataType.BLOOD_OXYGEN, 'spo2', '%');

  Future<int> _syncBodyTemperature(List<HealthDataPoint> data) =>
      _syncNumeric(data, HealthDataType.BODY_TEMPERATURE, 'temperature', '°F');

  Future<int> _syncNumeric(List<HealthDataPoint> data,
      HealthDataType healthType, String metricType, String unit) async {
    final points = data.where((d) => d.type == healthType).toList();
    if (points.isEmpty) return 0;

    int count = 0;
    for (final p in points) {
      final externalId =
          'hc_${metricType}_${p.dateFrom.millisecondsSinceEpoch}';
      if (await _db.getMetricByExternalId(externalId) != null) continue;

      final value = (p.value as NumericHealthValue).numericValue.toDouble();
      await _db.insertMetric(HealthMetricsCompanion(
        type: Value(metricType),
        value: Value(value),
        unit: Value(unit),
        recordedAt: Value(p.dateFrom),
        source: const Value('health_connect'),
        externalId: Value(externalId),
        createdAt: Value(DateTime.now()),
      ));
      count++;
    }
    return count;
  }
}
