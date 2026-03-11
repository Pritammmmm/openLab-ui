import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/models/api_response.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthApi {
  final DioClient _client;

  AuthApi(this._client);

  Future<ApiResponse<AuthResponse>> signInWithGoogle(String idToken) async {
    final response = await _client.post(
      ApiEndpoints.authGoogle,
      data: {'idToken': idToken},
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken(
      String refreshToken) async {
    final response = await _client.post(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refreshToken},
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> logout(String refreshToken) async {
    final response = await _client.post(
      ApiEndpoints.authLogout,
      data: {'refreshToken': refreshToken},
    );
    return ApiResponse.fromJson(response.data as Map<String, dynamic>, null);
  }

  Future<ApiResponse<UserModel>> getMe() async {
    final response = await _client.get(ApiEndpoints.authMe);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
