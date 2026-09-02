import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/health_database.dart';
import 'health_providers.dart';

final weeklyStepsProvider =
    StreamProvider.autoDispose<List<DailyLog>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  final fmt = DateFormat('yyyy-MM-dd');
  final today = DateTime.now();
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  return db.watchDailyLogRange(fmt.format(monday), fmt.format(sunday));
});
