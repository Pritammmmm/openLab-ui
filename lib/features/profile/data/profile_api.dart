import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileApi {
  final DioClient _client;

  ProfileApi(this._client);

  Future<ApiResponse<List<ProfileModel>>> getProfiles() async {
    final response = await _client.get(ApiEndpoints.profiles);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<ProfileModel>> createProfile(
      Map<String, dynamic> data) async {
    final response = await _client.post(
      ApiEndpoints.profiles,
      data: data,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => ProfileModel.fromJson(d as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProfileModel>> updateProfile(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      ApiEndpoints.profileById(id),
      data: data,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => ProfileModel.fromJson(d as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteProfile(String id) async {
    final response = await _client.delete(ApiEndpoints.profileById(id));
    return ApiResponse.fromJson(response.data as Map<String, dynamic>, null);
  }

  Future<ApiResponse<ProfileModel>> setDefault(String id) async {
    final response = await _client.patch(ApiEndpoints.profileSetDefault(id));
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => ProfileModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
