import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/report_repository.dart';
import '../models/report_model.dart';
import 'report_provider.dart';

enum UploadStatus { idle, uploading, processing, completed, failed }

class UploadState {
  final UploadStatus status;
  final double progress;
  final String? reportId;
  final ReportModel? report;
  final String? error;

  const UploadState({
    this.status = UploadStatus.idle,
    this.progress = 0,
    this.reportId,
    this.report,
    this.error,
  });

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? reportId,
    ReportModel? report,
    String? error,
  }) {
    return UploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      reportId: reportId ?? this.reportId,
      report: report ?? this.report,
      error: error,
    );
  }
}

final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  return UploadNotifier(ref.watch(reportRepositoryProvider));
});

class UploadNotifier extends StateNotifier<UploadState> {
  final ReportRepository _repository;

  UploadNotifier(this._repository) : super(const UploadState());

  Future<void> upload({
    required File file,
    required String profileId,
  }) async {
    state = const UploadState(status: UploadStatus.uploading, progress: 0);

    try {
      final reportId = await _repository.uploadReport(
        file: file,
        profileId: profileId,
        onSendProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(progress: sent / total);
          }
        },
      );

      state = UploadState(
        status: UploadStatus.processing,
        progress: 1.0,
        reportId: reportId,
      );
    } catch (e) {
      state = UploadState(
        status: UploadStatus.failed,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const UploadState();
  }

  void setCompleted(ReportModel report) {
    state = UploadState(
      status: UploadStatus.completed,
      progress: 1.0,
      reportId: report.id,
      report: report,
    );
  }

  void setFailed(String error) {
    state = UploadState(
      status: UploadStatus.failed,
      error: error,
    );
  }
}
