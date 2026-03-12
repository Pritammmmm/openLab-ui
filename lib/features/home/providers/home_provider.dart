import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../profile/data/profile_api.dart';
import '../../profile/models/profile_model.dart';
import '../../report/data/report_api.dart';
import '../../report/models/report_model.dart';
import '../../report/models/report_summary_model.dart';
import '../data/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    profileApi: ProfileApi(ref.watch(dioClientProvider)),
    reportApi: ReportApi(ref.watch(dioClientProvider)),
  );
});

final selectedProfileIndexProvider = StateProvider<int>((ref) => 0);

final profilesProvider =
    AsyncNotifierProvider<ProfilesNotifier, List<ProfileModel>>(
        ProfilesNotifier.new);

class ProfilesNotifier extends AsyncNotifier<List<ProfileModel>> {
  @override
  Future<List<ProfileModel>> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getProfiles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(homeRepositoryProvider);
      return repo.getProfiles();
    });
  }
}

final selectedProfileProvider = Provider<ProfileModel?>((ref) {
  final profiles = ref.watch(profilesProvider);
  final index = ref.watch(selectedProfileIndexProvider);
  return profiles.whenOrNull(
    data: (list) {
      if (list.isEmpty) return null;
      final defaultIndex = list.indexWhere((p) => p.isDefault);
      final effectiveIndex = index == 0 && defaultIndex >= 0 ? defaultIndex : index;
      if (effectiveIndex >= 0 && effectiveIndex < list.length) {
        return list[effectiveIndex];
      }
      return list.first;
    },
  );
});

final latestReportProvider =
    FutureProvider.family<ReportSummaryModel?, String>((ref, profileId) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getLatestReport(profileId);
});

final latestFullReportProvider =
    FutureProvider.family<ReportModel?, String>((ref, profileId) async {
  final summary = await ref.watch(latestReportProvider(profileId).future);
  if (summary == null || !summary.isCompleted) return null;
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getFullReport(summary.id);
});
