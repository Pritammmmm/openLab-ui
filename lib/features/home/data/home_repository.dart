import '../../profile/data/profile_api.dart';
import '../../profile/models/profile_model.dart';
import '../../report/data/report_api.dart';
import '../../report/models/report_model.dart';
import '../../report/models/report_summary_model.dart';

class HomeRepository {
  final ProfileApi _profileApi;
  final ReportApi _reportApi;

  HomeRepository({
    required ProfileApi profileApi,
    required ReportApi reportApi,
  })  : _profileApi = profileApi,
        _reportApi = reportApi;

  Future<List<ProfileModel>> getProfiles() async {
    final response = await _profileApi.getProfiles();
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ReportModel?> getFullReport(String reportId) async {
    final response = await _reportApi.getReport(reportId);
    if (response.success && response.data != null) {
      return response.data!;
    }
    return null;
  }

  Future<ReportSummaryModel?> getLatestReport(String profileId) async {
    final response = await _reportApi.getReportsByProfile(
      profileId,
      page: 1,
      limit: 1,
      status: 'completed',
    );
    if (response.success && response.data != null && response.data!.isNotEmpty) {
      return response.data!.first;
    }
    return null;
  }
}
