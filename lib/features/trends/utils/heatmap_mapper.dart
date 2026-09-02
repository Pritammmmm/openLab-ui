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
/// Prefers backend healthScore (same formula, authoritative for all months).
/// Falls back to client-side computation from statusCounts.
int? computeScore(ReportSummaryModel report) {
  if (report.healthScore?.score != null) return report.healthScore!.score;
  final counts = report.statusCounts;
  if (counts.total > 0) {
    return ((counts.green * 100 + counts.yellow * 20) / counts.total).round();
  }
  return null;
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
///   - **Current month**: uses [currentMonthScore] if provided (computed
///     client-side from the full report's actual parameters). Falls back
///     to the summary's statusCounts only if no full report is available.
///   - **Past months**: the **last** report's score from that month (frozen
///     snapshot of where health stood when the month ended).
///   - **Empty months**: no reports → gray block.
///
/// [currentMonthScore] should be computed from the full report's parameters
/// using the same formula as the health score ring (green=100%, yellow=20%,
/// red=0%) so that both widgets always agree.
List<HeatmapCell> buildMonthlyGrid(
  List<ReportSummaryModel> reports, {
  int? currentMonthScore,
}) {
  final now = DateTime.now();
  final months = getLast12Months();

  // ── Step 1: Find the globally latest completed report ──
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

  // ── Step 2: For each past month, find the last report & count ──
  // Key: "year-month", Value: {lastReport, count}
  final Map<String, _MonthData> monthlyData = {};
  for (final report in reports) {
    if (!report.isCompleted) continue;
    final date = report.reportDate ?? report.uploadDate;
    final key = '${date.year}-${date.month}';
    final existing = monthlyData[key];
    if (existing == null) {
      monthlyData[key] = _MonthData(lastReport: report, count: 1);
    } else {
      existing.count++;
      final existingDate =
          existing.lastReport.reportDate ?? existing.lastReport.uploadDate;
      if (date.isAfter(existingDate)) {
        existing.lastReport = report;
      }
    }
  }

  // ── Step 3: Build the 12 cells ──
  return months.map((mi) {
    final isCurrent = mi.year == now.year && mi.month == now.month;
    final key = '${mi.year}-${mi.month}';
    final data = monthlyData[key];

    int? cellScore;
    int reportCount;

    if (isCurrent) {
      // Current month: prefer the client-computed score from full report
      cellScore = currentMonthScore ?? latestScore;
      reportCount = data?.count ?? 0;
    } else {
      // Past month = last report's score from that month (frozen)
      if (data != null) {
        cellScore = computeScore(data.lastReport);
      }
      reportCount = data?.count ?? 0;
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

class _MonthData {
  ReportSummaryModel lastReport;
  int count;
  _MonthData({required this.lastReport, required this.count});
}
