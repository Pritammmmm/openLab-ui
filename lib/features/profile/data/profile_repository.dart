import '../models/profile_model.dart';
import 'profile_api.dart';

class ProfileRepository {
  final ProfileApi _api;

  ProfileRepository(this._api);

  Future<List<ProfileModel>> getProfiles() async {
    final response = await _api.getProfiles();
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ProfileModel> createProfile({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    String relation = 'self',
  }) async {
    final response = await _api.createProfile({
      'name': name,
      'date_of_birth': dateOfBirth.toUtc().toIso8601String(),
      'gender': gender,
      'relation': relation,
    });
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ProfileModel> updateProfile(
    String id, {
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? relation,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toUtc().toIso8601String();
    if (gender != null) data['gender'] = gender;
    if (relation != null) data['relation'] = relation;

    final response = await _api.updateProfile(id, data);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<void> deleteProfile(String id) async {
    final response = await _api.deleteProfile(id);
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<ProfileModel> setDefault(String id) async {
    final response = await _api.setDefault(id);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
