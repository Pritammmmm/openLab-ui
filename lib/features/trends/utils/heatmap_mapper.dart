import '../../report/models/report_summary_model.dart';

/// GitHub-style green gradient levels for heatmap blocks.
enum HeatmapLevel { empty, low, medium, high, excellent }

/// A single month block in the heatmap.
class HeatmapCell {
  final DateTime date;
  final int? score;
  final HeatmapLevel level;
  final String monthLabel;
  final int reportCount;
  final bool isCurrentMonth;

  const HeatmapCell({
    required this.date,
    this.score,
    this.level = HeatmapLevel.empty,
    this.monthLabel = '',
    this.reportCount = 0,
    this.isCurrentMonth = false,
  });
}

/// Computes the health score for a report.
int? computeScore(ReportSummaryModel report) {
  final counts = report.statusCounts;
  if (counts.total > 0) {
    return ((counts.green * 100 + counts.yellow * 20) / counts.total).round();
  }
  if (report.healthScore?.score != null) return report.healthScore!.score;
  return 75;
}

HeatmapLevel levelFromScore(int? score) {
  if (score == null) return HeatmapLevel.empty;
  if (score >= 91) return HeatmapLevel.excellent;
  if (score >= 71) return HeatmapLevel.high;
  if (score >= 51) return HeatmapLevel.medium;
  return HeatmapLevel.low;
}

/// Month info for labels.
class MonthInfo {
  final int year;
  final int month;
  final String label;

  MonthInfo(this.year, this.month)
      : label = const [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ][month - 1];
}

/// Returns the last 12 months ending at the current month.
List<MonthInfo> getLast12Months() {
  final now = DateTime.now();
  return List.generate(12, (i) {
    final d = DateTime(now.year, now.month - 11 + i);
    return MonthInfo(d.year, d.month);
  });
}

/// Builds 12 monthly heatmap cells from report history.
///
/// Logic:
///   - **Current month**: always shows the latest report's health score,
///     regardless of when that report was uploaded. This reflects
///     "where your health is right now."
///   - **Past months**: average health score of all reports uploaded
///     during that calendar month (historical snapshot).
///   - **Empty months**: no reports at all → gray block.
List<HeatmapCell> buildMonthlyGrid(List<ReportSummaryModel> reports) {
  final now = DateTime.now();
  final months = getLast12Months();

  // ── Step 1: Find the latest report (most recent by date) ──
  ReportSummaryModel? latestReport;
  for (final report in reports) {
    if (!report.isCompleted) continue;
    if (latestReport == null) {
      latestReport = report;
    } else {
      final current = latestReport.reportDate ?? latestReport.uploadDate;
      final candidate = report.reportDate ?? report.uploadDate;
      if (candidate.isAfter(current)) {
        latestReport = report;
      }
    }
  }
  final latestScore =
      latestReport != null ? computeScore(latestReport) : null;

  // ── Step 2: Group scores by calendar month for past months ──
  final Map<String, List<int>> monthlyScores = {};
  for (final report in reports) {
    if (!report.isCompleted) continue;
    final date = report.reportDate ?? report.uploadDate;
    final score = computeScore(report);
    if (score == null) continue;
    final key = '${date.year}-${date.month}';
    monthlyScores.putIfAbsent(key, () => []).add(score);
  }

  // ── Step 3: Build the 12 cells ──
  return months.map((mi) {
    final isCurrent = mi.year == now.year && mi.month == now.month;
    final key = '${mi.year}-${mi.month}';
    final monthReports = monthlyScores[key];

    int? cellScore;
    int reportCount;

    if (isCurrent) {
      // Current month = latest health score (real-time)
      cellScore = latestScore;
      reportCount = monthReports?.length ?? 0;
    } else {
      // Past month = average of that month's reports
      if (monthReports != null && monthReports.isNotEmpty) {
        cellScore =
            (monthReports.reduce((a, b) => a + b) / monthReports.length)
                .round();
      }
      reportCount = monthReports?.length ?? 0;
    }

    return HeatmapCell(
      date: DateTime(mi.year, mi.month),
      score: cellScore,
      level: levelFromScore(cellScore),
      monthLabel: mi.label,
      reportCount: reportCount,
      isCurrentMonth: isCurrent,
    );
  }).toList();
}
