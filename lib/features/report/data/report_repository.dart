import 'dart:io';
import '../models/report_model.dart';
import '../models/report_summary_model.dart';
import 'report_api.dart';

class ReportRepository {
  final ReportApi _api;

  ReportRepository(this._api);

  Future<String> uploadReport({
    required File file,
    required String profileId,
    void Function(int, int)? onSendProgress,
  }) async {
    final response = await _api.uploadReport(
      file: file,
      profileId: profileId,
      onSendProgress: onSendProgress,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ReportModel> getReport(String reportId) async {
    final response = await _api.getReport(reportId);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<String> getReportStatus(String reportId) async {
    final response = await _api.getReportStatus(reportId);
    if (response.success && response.data != null) {
      return response.data!['status'] as String? ?? 'processing';
    }
    throw Exception(response.message);
  }

  Future<List<ReportSummaryModel>> getReportsByProfile(
    String profileId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _api.getReportsByProfile(
      profileId,
      page: page,
      limit: limit,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<void> deleteReport(String reportId) async {
    final response = await _api.deleteReport(reportId);
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
