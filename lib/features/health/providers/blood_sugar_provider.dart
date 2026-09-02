import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

final bloodSugarListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('bloodSugar', limit: 50);
});

final latestBloodSugarProvider =
    StreamProvider.autoDispose<HealthMetric?>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchLatestMetric('bloodSugar');
});

final bloodSugarActionsProvider = Provider<BloodSugarActions>((ref) {
  return BloodSugarActions(ref.watch(healthDatabaseProvider));
});

class BloodSugarActions {
  final HealthDatabase _db;

  BloodSugarActions(this._db);

  Future<void> log({
    required double value,
    required String subType,
    DateTime? recordedAt,
    String? notes,
  }) async {
    await _db.insertMetric(HealthMetricsCompanion.insert(
      type: 'bloodSugar',
      value: value,
      subType: Value(subType),
      unit: 'mg/dL',
      recordedAt: recordedAt ?? DateTime.now(),
      notes: Value(notes),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> delete(int id) => _db.deleteMetric(id);
}
