import '../../report/data/report_api.dart';
import '../../report/models/report_summary_model.dart';

class HistoryRepository {
  final ReportApi _reportApi;

  HistoryRepository(this._reportApi);

  Future<List<ReportSummaryModel>> getReports(
    String profileId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _reportApi.getReportsByProfile(
      profileId,
      page: page,
      limit: limit,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
