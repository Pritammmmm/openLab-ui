import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/trends_repository.dart';

final trendsRepositoryProvider = Provider<TrendsRepository>((ref) {
  return TrendsRepository(ref.watch(dioClientProvider));
});

final selectedTrendCategoryProvider = StateProvider<String?>((ref) => null);
final selectedTrendParameterProvider = StateProvider<String?>((ref) => null);

final trendsDataProvider = FutureProvider.family<List<TrendParameter>, String>(
    (ref, profileId) async {
  final plan = ref.watch(activePlanProvider);
  if (plan == PlanTier.free) return [];

  final repo = ref.watch(trendsRepositoryProvider);
  final category = ref.watch(selectedTrendCategoryProvider);
  final parameter = ref.watch(selectedTrendParameterProvider);

  return repo.getTrends(
    profileId,
    category: category,
    parameterName: parameter,
  );
});
