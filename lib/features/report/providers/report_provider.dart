import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/report_api.dart';
import '../data/report_repository.dart';
import '../models/report_model.dart';

final reportApiProvider = Provider<ReportApi>((ref) {
  return ReportApi(ref.watch(dioClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(reportApiProvider));
});

final reportDetailProvider =
    FutureProvider.family<ReportModel, String>((ref, reportId) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getReport(reportId);
});

final reportStatusProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, reportId) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getReportStatus(reportId);
});
