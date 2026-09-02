import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import 'daily_log_provider.dart';
import 'health_providers.dart';

final todayFoodEntriesProvider =
    StreamProvider.autoDispose<List<FoodEntry>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchFoodEntries(DateTime.now());
});

final foodLogActionsProvider = Provider<FoodLogActions>((ref) {
  return FoodLogActions(
    ref.watch(healthDatabaseProvider),
    ref.watch(dailyLogActionsProvider),
  );
});

class FoodLogActions {
  final HealthDatabase _db;
  final DailyLogActions _logActions;

  FoodLogActions(this._db, this._logActions);

  Future<void> add({
    required String name,
    required int calories,
    required String mealType,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    final now = DateTime.now();
    await _db.insertFoodEntry(FoodEntriesCompanion.insert(
      name: name,
      calories: calories,
      mealType: mealType,
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      consumedAt: now,
      createdAt: now,
    ));
    await _logActions.syncCaloriesFromFood();
  }

  Future<void> delete(int id) async {
    await _db.deleteFoodEntry(id);
    await _logActions.syncCaloriesFromFood();
  }
}
