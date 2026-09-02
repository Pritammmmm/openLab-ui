import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

final weightListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('weight', limit: 50);
});

final latestWeightProvider =
    StreamProvider.autoDispose<HealthMetric?>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchLatestMetric('weight');
});

final weightActionsProvider = Provider<WeightActions>((ref) {
  return WeightActions(ref.watch(healthDatabaseProvider));
});

class WeightActions {
  final HealthDatabase _db;

  WeightActions(this._db);

  Future<void> log({
    required double weight,
    double? heightCm,
    DateTime? recordedAt,
    String? notes,
  }) async {
    await _db.insertMetric(HealthMetricsCompanion.insert(
      type: 'weight',
      value: weight,
      value2: Value(heightCm),
      unit: 'kg',
      recordedAt: recordedAt ?? DateTime.now(),
      notes: Value(notes),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> delete(int id) => _db.deleteMetric(id);

  static double computeBmi(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
