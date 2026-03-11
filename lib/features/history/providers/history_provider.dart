import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../report/data/report_api.dart';
import '../../report/models/report_summary_model.dart';
import '../data/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ReportApi(ref.watch(dioClientProvider)));
});

class HistoryState {
  final List<ReportSummaryModel> reports;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const HistoryState({
    this.reports = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  HistoryState copyWith({
    List<ReportSummaryModel>? reports,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return HistoryState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

final historyNotifierProvider = StateNotifierProvider.family<
    HistoryNotifier, HistoryState, String>((ref, profileId) {
  return HistoryNotifier(
    ref.watch(historyRepositoryProvider),
    profileId,
  );
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;
  final String _profileId;
  static const _pageSize = 10;

  HistoryNotifier(this._repository, this._profileId)
      : super(const HistoryState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports = await _repository.getReports(
        _profileId,
        page: 1,
        limit: _pageSize,
      );
      state = HistoryState(
        reports: reports,
        hasMore: reports.length >= _pageSize,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final reports = await _repository.getReports(
        _profileId,
        page: nextPage,
        limit: _pageSize,
      );
      state = state.copyWith(
        reports: [...state.reports, ...reports],
        hasMore: reports.length >= _pageSize,
        currentPage: nextPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const HistoryState(isLoading: true);
    await loadInitial();
  }
}
