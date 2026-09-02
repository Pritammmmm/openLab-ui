import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

final todayLogProvider = StreamProvider.autoDispose<DailyLog?>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchDailyLog(_todayKey());
});

final dailyLogActionsProvider = Provider<DailyLogActions>((ref) {
  return DailyLogActions(ref.watch(healthDatabaseProvider));
});

class DailyLogActions {
  final HealthDatabase _db;

  DailyLogActions(this._db);

  Future<void> addWater({int glasses = 1}) async {
    try {
      final key = _todayKey();
      final existing = await _db.getDailyLog(key);
      final current = existing?.waterGlasses ?? 0;
      await _db.upsertDailyLog(DailyLogsCompanion(
        dateKey: Value(key),
        waterGlasses: Value(current + glasses),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      debugPrint('addWater error: $e');
    }
  }

  Future<void> removeWater() async {
    try {
      final key = _todayKey();
      final existing = await _db.getDailyLog(key);
      final current = existing?.waterGlasses ?? 0;
      if (current <= 0) return;
      await _db.upsertDailyLog(DailyLogsCompanion(
        dateKey: Value(key),
        waterGlasses: Value(current - 1),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      debugPrint('removeWater error: $e');
    }
  }

  Future<void> resetWater() async {
    try {
      final key = _todayKey();
      await _db.upsertDailyLog(DailyLogsCompanion(
        dateKey: Value(key),
        waterGlasses: const Value(0),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      debugPrint('resetWater error: $e');
    }
  }

  Future<void> updateSteps(int steps) async {
    final key = _todayKey();
    await _db.upsertDailyLog(DailyLogsCompanion(
      dateKey: Value(key),
      steps: Value(steps),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateSleep(int minutes, {String? quality}) async {
    final key = _todayKey();
    await _db.upsertDailyLog(DailyLogsCompanion(
      dateKey: Value(key),
      sleepMinutes: Value(minutes),
      sleepQuality: Value(quality),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateCalories(int consumed) async {
    final key = _todayKey();
    await _db.upsertDailyLog(DailyLogsCompanion(
      dateKey: Value(key),
      caloriesConsumed: Value(consumed),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> syncCaloriesFromFood() async {
    final key = _todayKey();
    final entries = await _db.getFoodEntriesForDate(DateTime.now());
    final total = entries.fold<int>(0, (s, e) => s + e.calories);
    await _db.upsertDailyLog(DailyLogsCompanion(
      dateKey: Value(key),
      caloriesConsumed: Value(total),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
