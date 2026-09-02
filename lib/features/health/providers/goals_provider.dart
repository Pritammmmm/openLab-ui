import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

final goalsListProvider = StreamProvider.autoDispose<List<HealthGoal>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchGoals();
});

final goalActionsProvider = Provider<GoalActions>((ref) {
  return GoalActions(ref.watch(healthDatabaseProvider));
});

class GoalActions {
  final HealthDatabase _db;

  GoalActions(this._db);

  Future<void> upsert({
    required String metricType,
    required double targetValue,
    required String unit,
    double? minValue,
    double? maxValue,
  }) async {
    final existing = await _db.getGoalForMetric(metricType);
    if (existing != null) {
      await _db.updateGoal(HealthGoalsCompanion(
        id: Value(existing.id),
        metricType: Value(metricType),
        targetValue: Value(targetValue),
        unit: Value(unit),
        minValue: Value(minValue),
        maxValue: Value(maxValue),
        isActive: const Value(true),
        createdAt: Value(existing.createdAt),
      ));
    } else {
      await _db.insertGoal(HealthGoalsCompanion(
        metricType: Value(metricType),
        targetValue: Value(targetValue),
        unit: Value(unit),
        minValue: Value(minValue),
        maxValue: Value(maxValue),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  Future<void> delete(int id) => _db.deleteGoal(id);
}
