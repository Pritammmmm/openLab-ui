import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_database.dart';
import '../data/health_api.dart';
import '../../../core/providers/core_providers.dart';

final healthDatabaseProvider = Provider<HealthDatabase>((ref) {
  return HealthDatabase.instance;
});

final healthApiProvider = Provider<HealthApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HealthApi(dioClient);
});
