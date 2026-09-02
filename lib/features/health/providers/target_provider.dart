import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goals_provider.dart';

class HealthTargets {
  final int calories;
  final int water;
  final int steps;
  final int sleepMinutes;

  const HealthTargets({
    this.calories = 2000,
    this.water = 8,
    this.steps = 10000,
    this.sleepMinutes = 480,
  });
}

final healthTargetsProvider =
    Provider.autoDispose<AsyncValue<HealthTargets>>((ref) {
  final goalsAsync = ref.watch(goalsListProvider);
  return goalsAsync.whenData((goals) {
    int cal = 2000, water = 8, steps = 10000, sleep = 480;
    for (final g in goals) {
      switch (g.metricType) {
        case 'calories':
          cal = g.targetValue.toInt();
        case 'water':
          water = g.targetValue.toInt();
        case 'steps':
          steps = g.targetValue.toInt();
        case 'sleep':
          sleep = g.targetValue.toInt();
      }
    }
    return HealthTargets(
        calories: cal, water: water, steps: steps, sleepMinutes: sleep);
  });
});
