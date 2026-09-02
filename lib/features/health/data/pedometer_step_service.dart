import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'health_database.dart';
import 'package:drift/drift.dart';

const _keyBaseline = 'pedometer_baseline_at_midnight';
const _keyBaselineDate = 'pedometer_baseline_date';
const _keyLastRaw = 'pedometer_last_raw_value';
const _keyAccumulated = 'pedometer_accumulated_before_reboot';
const _keyEnabled = 'pedometer_sensor_enabled';

class PedometerStepService {
  final HealthDatabase _db;
  StreamSubscription<StepCount>? _stepSub;
  final _stepsController = StreamController<int>.broadcast();
  bool _running = false;

  int _baselineAtMidnight = 0;
  String _baselineDate = '';
  int _lastRawValue = 0;
  int _accumulatedBeforeReboot = 0;
  int _todaySteps = 0;

  PedometerStepService(this._db);

  Stream<int> get todaySensorSteps => _stepsController.stream;
  int get currentSteps => _todaySteps;
  bool get isRunning => _running;

  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    debugPrint('[Pedometer] ACTIVITY_RECOGNITION permission: $status');
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.activityRecognition.isGranted;
  }

  Future<void> start() async {
    if (_running) return;

    final granted = await hasPermission();
    if (!granted) {
      debugPrint('[Pedometer] Permission not granted, cannot start');
      return;
    }

    await _loadState();
    _running = true;

    _stepSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepError,
    );

    debugPrint('[Pedometer] Started — baseline=$_baselineAtMidnight, date=$_baselineDate, accumulated=$_accumulatedBeforeReboot');
  }

  Future<void> stop() async {
    _running = false;
    await _stepSub?.cancel();
    _stepSub = null;
    await _saveState();
    debugPrint('[Pedometer] Stopped');
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _baselineAtMidnight = prefs.getInt(_keyBaseline) ?? 0;
    _baselineDate = prefs.getString(_keyBaselineDate) ?? '';
    _lastRawValue = prefs.getInt(_keyLastRaw) ?? 0;
    _accumulatedBeforeReboot = prefs.getInt(_keyAccumulated) ?? 0;
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBaseline, _baselineAtMidnight);
    await prefs.setString(_keyBaselineDate, _baselineDate);
    await prefs.setInt(_keyLastRaw, _lastRawValue);
    await prefs.setInt(_keyAccumulated, _accumulatedBeforeReboot);
  }

  void _onStepCount(StepCount event) {
    final rawValue = event.steps;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // First ever reading — initialize baseline
    if (_baselineDate.isEmpty) {
      _baselineAtMidnight = rawValue;
      _baselineDate = today;
      _lastRawValue = rawValue;
      _accumulatedBeforeReboot = 0;
      _todaySteps = 0;
      _stepsController.add(0);
      _saveState();
      debugPrint('[Pedometer] First reading — baseline set to $rawValue');
      return;
    }

    // Detect device reboot: raw value dropped significantly
    if (rawValue < _lastRawValue - 100) {
      final stepsBeforeReboot = _lastRawValue - _baselineAtMidnight;
      _accumulatedBeforeReboot += stepsBeforeReboot.clamp(0, 1000000);
      _baselineAtMidnight = rawValue;
      debugPrint('[Pedometer] Reboot detected — preserved $_accumulatedBeforeReboot steps, new baseline=$rawValue');
    }

    // Detect midnight rollover
    if (today != _baselineDate) {
      _handleMidnightRollover(today, rawValue);
    }

    _lastRawValue = rawValue;
    _todaySteps = _accumulatedBeforeReboot + (rawValue - _baselineAtMidnight).clamp(0, 1000000);

    _stepsController.add(_todaySteps);
    _writeToDb(today, _todaySteps);
    _saveState();
  }

  void _handleMidnightRollover(String newDate, int currentRaw) {
    // Finalize yesterday's count
    final yesterdaySteps = _accumulatedBeforeReboot +
        (_lastRawValue - _baselineAtMidnight).clamp(0, 1000000);
    _writeToDb(_baselineDate, yesterdaySteps);

    debugPrint('[Pedometer] Midnight rollover — yesterday=$_baselineDate had $yesterdaySteps steps');

    // Reset for new day
    _baselineAtMidnight = currentRaw;
    _baselineDate = newDate;
    _accumulatedBeforeReboot = 0;
    _todaySteps = 0;
  }

  Future<void> _writeToDb(String dateKey, int sensorSteps) async {
    if (sensorSteps <= 0) return;

    try {
      final existing = await _db.getDailyLog(dateKey);
      final existingSteps = existing?.steps ?? 0;
      final existingSource = existing?.source ?? 'manual';

      // Only write if sensor has MORE steps than what's already stored,
      // unless the existing data came from the sensor (always update our own count)
      if (sensorSteps > existingSteps || existingSource == 'sensor') {
        final finalSteps = sensorSteps > existingSteps ? sensorSteps : existingSteps;
        await _db.upsertDailyLog(DailyLogsCompanion(
          dateKey: Value(dateKey),
          steps: Value(finalSteps),
          source: Value(sensorSteps >= existingSteps ? 'sensor' : existingSource),
          updatedAt: Value(DateTime.now()),
        ));
      }
    } catch (e) {
      debugPrint('[Pedometer] DB write error: $e');
    }
  }

  void _onStepError(dynamic error) {
    debugPrint('[Pedometer] Sensor error: $error');
  }

  Future<void> dispose() async {
    await stop();
    await _stepsController.close();
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }
}
