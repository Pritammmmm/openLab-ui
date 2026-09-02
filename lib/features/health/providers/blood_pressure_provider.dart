import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

final bloodPressureListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('bloodPressure', limit: 50);
});

final latestBloodPressureProvider =
    StreamProvider.autoDispose<HealthMetric?>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchLatestMetric('bloodPressure');
});

final bloodPressureActionsProvider = Provider<BloodPressureActions>((ref) {
  return BloodPressureActions(ref.watch(healthDatabaseProvider));
});

class BloodPressureActions {
  final HealthDatabase _db;

  BloodPressureActions(this._db);

  Future<void> log({
    required double systolic,
    required double diastolic,
    double? pulse,
    DateTime? recordedAt,
    String? notes,
  }) async {
    await _db.insertMetric(HealthMetricsCompanion.insert(
      type: 'bloodPressure',
      value: systolic,
      value2: Value(diastolic),
      value3: Value(pulse),
      unit: 'mmHg',
      recordedAt: recordedAt ?? DateTime.now(),
      notes: Value(notes),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> delete(int id) => _db.deleteMetric(id);
}
