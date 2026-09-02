import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

final latestHeartRateProvider =
    StreamProvider.autoDispose<HealthMetric?>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchLatestMetric('heartRate');
});

final heartRateListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('heartRate', limit: 50);
});
