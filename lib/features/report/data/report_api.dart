import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/report_model.dart';
import '../models/report_summary_model.dart';

class ReportApi {
  final DioClient _client;

  ReportApi(this._client);

  Future<ApiResponse<String>> uploadReport({
    required File file,
    required String profileId,
    void Function(int, int)? onSendProgress,
  }) async {
    final fileName = file.path.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'profile_id': profileId,
    });

    final response = await _client.post(
      ApiEndpoints.reportUpload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) {
        final map = data as Map<String, dynamic>;
        return map['reportId'] as String? ?? map['id'] as String? ?? '';
      },
    );
  }

  Future<ApiResponse<ReportModel>> getReport(String reportId) async {
    final response = await _client.get(ApiEndpoints.reportById(reportId));
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => ReportModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getReportStatus(
      String reportId) async {
    final response = await _client.get(ApiEndpoints.reportStatus(reportId));
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<ReportSummaryModel>>> getReportsByProfile(
    String profileId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _client.get(
      ApiEndpoints.reportsByProfile(profileId),
      queryParameters: {'page': page, 'limit': limit},
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) {
        final list = data is List ? data : (data as Map<String, dynamic>)['reports'] as List<dynamic>? ?? [];
        return list
            .map((e) => ReportSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<void>> deleteReport(String reportId) async {
    final response = await _client.delete(ApiEndpoints.reportById(reportId));
    return ApiResponse.fromJson(response.data as Map<String, dynamic>, null);
  }

  Future<ApiResponse<Map<String, dynamic>>> getComparison(
      String reportId) async {
    final response = await _client.get(ApiEndpoints.reportCompare(reportId));
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );
  }
}
