import '../../report/models/report_summary_model.dart';

/// Color level for heatmap cells based on health score.
enum HeatmapLevel {
  empty, // no report
  critical, // 0–50
  attention, // 51–70
  mild, // 71–90
  excellent, // 91–100
}

/// A single cell in the heatmap grid.
class HeatmapCell {
  final DateTime date;
  final int? score;
  final HeatmapLevel level;

  const HeatmapCell({
    required this.date,
    this.score,
    this.level = HeatmapLevel.empty,
  });
}

/// Computes the health score for a report — tries every available field.
int? _computeScore(ReportSummaryModel report) {
  // 1. Client-side weighted calculation from statusCounts
  final counts = report.statusCounts;
  if (counts.total > 0) {
    return ((counts.green * 100 + counts.yellow * 20) / counts.total).round();
  }

  // 2. Server-provided score
  if (report.healthScore?.score != null) return report.healthScore!.score;

  // 3. Any report that exists gets a default
  return 75;
}

HeatmapLevel levelFromScore(int? score) {
  if (score == null) return HeatmapLevel.empty;
  if (score >= 91) return HeatmapLevel.excellent;
  if (score >= 71) return HeatmapLevel.mild;
  if (score >= 51) return HeatmapLevel.attention;
  return HeatmapLevel.critical;
}

/// Month info for building dynamic grids.
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

/// Returns 12 months starting from the current month, ending 11 months ahead.
/// e.g. if now is March 2026: Mar 2026, Apr 2026, ..., Jan 2027, Feb 2027
List<MonthInfo> getLast12Months() {
  final now = DateTime.now();
  return List.generate(12, (i) {
    final d = DateTime(now.year, now.month + i);
    return MonthInfo(d.year, d.month);
  });
}

/// Groups reports into a weekly preview grid (12 months x 5 weeks).
/// Columns = months (oldest → current), Rows = weeks of month (0–4).
/// Returns flat list of 60 cells ordered: [month0-week0, month0-week1, ..., month11-week4].
List<HeatmapCell> buildPreviewGrid(List<ReportSummaryModel> reports) {
  final months = getLast12Months();

  // Build lookup: "year-month-week" → worst score
  final Map<String, int> worstScores = {};

  for (final report in reports) {
    final date = report.reportDate ?? report.uploadDate;
    final score = _computeScore(report);
    if (score == null) continue;

    final weekOfMonth = ((date.day - 1) / 7).floor().clamp(0, 4);
    final key = '${date.year}-${date.month}-$weekOfMonth';

    final existing = worstScores[key];
    if (existing == null || score < existing) {
      worstScores[key] = score;
    }
  }

  final cells = <HeatmapCell>[];
  for (final mi in months) {
    for (int week = 0; week < 5; week++) {
      final key = '${mi.year}-${mi.month}-$week';
      final score = worstScores[key];
      cells.add(HeatmapCell(
        date: DateTime(mi.year, mi.month, week * 7 + 1),
        score: score,
        level: levelFromScore(score),
      ));
    }
  }

  return cells;
}

/// Groups reports into daily cells for the detailed heatmap (last 12 months).
Map<String, HeatmapCell> buildDetailedGrid(List<ReportSummaryModel> reports) {
  final now = DateTime.now();
  final months = getLast12Months();
  final start = DateTime(months.first.year, months.first.month, 1);

  // Build lookup: "year-month-day" → worst score
  final Map<String, int> worstScores = {};

  for (final report in reports) {
    final date = report.reportDate ?? report.uploadDate;
    if (date.isBefore(start)) continue;

    final score = _computeScore(report);
    if (score == null) continue;

    final key = '${date.year}-${date.month}-${date.day}';
    final existing = worstScores[key];
    if (existing == null || score < existing) {
      worstScores[key] = score;
    }
  }

  final Map<String, HeatmapCell> cells = {};
  for (var d = start;
      !d.isAfter(now);
      d = d.add(const Duration(days: 1))) {
    final key = '${d.year}-${d.month}-${d.day}';
    final score = worstScores[key];
    cells[key] = HeatmapCell(
      date: d,
      score: score,
      level: levelFromScore(score),
    );
  }

  return cells;
}
