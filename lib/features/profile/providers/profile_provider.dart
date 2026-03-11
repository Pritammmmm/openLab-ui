import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/profile_api.dart';
import '../data/profile_repository.dart';
import '../models/profile_model.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(dioClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileApiProvider));
});

final manageProfilesProvider =
    AsyncNotifierProvider<ManageProfilesNotifier, List<ProfileModel>>(
        ManageProfilesNotifier.new);

class ManageProfilesNotifier extends AsyncNotifier<List<ProfileModel>> {
  @override
  Future<List<ProfileModel>> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getProfiles();
  }

  Future<void> createProfile({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    String relation = 'self',
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.createProfile(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      relation: relation,
    );
    ref.invalidateSelf();
  }

  Future<void> updateProfile(
    String id, {
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? relation,
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.updateProfile(
      id,
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      relation: relation,
    );
    ref.invalidateSelf();
  }

  Future<void> deleteProfile(String id) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.deleteProfile(id);
    ref.invalidateSelf();
  }

  Future<void> setDefault(String id) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.setDefault(id);
    ref.invalidateSelf();
  }
}
