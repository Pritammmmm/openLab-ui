import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/home_provider.dart';
import '../../report/models/parameter_model.dart';
import '../data/trends_repository.dart';
import 'trends_provider.dart';

/// Picks the most critical parameter from the latest report.
/// Priority: red (highest deviation) → yellow → first green.
final mostCriticalParameterProvider =
    Provider.family<ParameterModel?, String>((ref, profileId) {
  final fullReport =
      ref.watch(latestFullReportProvider(profileId)).valueOrNull;
  if (fullReport == null || fullReport.parameters.isEmpty) return null;

  final params = fullReport.parameters;

  // Red parameters sorted by deviation from reference range
  final reds = params.where((p) => p.trafficLight == 'red').toList();
  if (reds.isNotEmpty) {
    reds.sort((a, b) => _deviation(b).compareTo(_deviation(a)));
    return reds.first;
  }

  // Yellow parameters
  final yellows = params.where((p) => p.trafficLight == 'yellow').toList();
  if (yellows.isNotEmpty) {
    yellows.sort((a, b) => _deviation(b).compareTo(_deviation(a)));
    return yellows.first;
  }

  return params.first;
});

double _deviation(ParameterModel p) {
  if (p.refRange == null) return 0;
  final min = p.refRange!.min ?? 0;
  final max = p.refRange!.max ?? 0;
  final mid = (min + max) / 2;
  if (mid == 0) return 0;
  return ((p.value - mid) / mid).abs();
}

/// All parameters from the latest report (for dropdown selection).
final availableParametersProvider =
    Provider.family<List<ParameterModel>, String>((ref, profileId) {
  final fullReport =
      ref.watch(latestFullReportProvider(profileId)).valueOrNull;
  if (fullReport == null) return [];
  return fullReport.parameters;
});

/// Currently selected parameter name on the detail screen.
final selectedDetailParameterProvider = StateProvider<String?>((ref) => null);

/// Fetches trend data for the sparkline preview (most critical parameter).
final trendPreviewProvider =
    FutureProvider.family<TrendParameter?, String>((ref, profileId) async {
  final critical = ref.watch(mostCriticalParameterProvider(profileId));
  if (critical == null) return null;

  final repo = ref.watch(trendsRepositoryProvider);
  try {
    final result = await repo.getTrends(profileId, parameterName: critical.name);
    if (result.isNotEmpty && result.first.dataPoints.length >= 3) {
      return result.first;
    }
  } catch (_) {}
  return null;
});

/// Fetches trend data for the detail screen's selected parameter.
final trendDetailProvider =
    FutureProvider.family<TrendParameter?, String>((ref, profileId) async {
  final selected = ref.watch(selectedDetailParameterProvider);
  final critical = ref.watch(mostCriticalParameterProvider(profileId));
  final paramName = selected ?? critical?.name;
  if (paramName == null) return null;

  final repo = ref.watch(trendsRepositoryProvider);
  final result = await repo.getTrends(profileId, parameterName: paramName);
  return result.isNotEmpty ? result.first : null;
});
