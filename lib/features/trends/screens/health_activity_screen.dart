import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../../home/providers/home_provider.dart';
import '../../history/providers/history_provider.dart';
import '../utils/heatmap_mapper.dart';
import '../widgets/health_heatmap_cell.dart';

class HealthActivityScreen extends ConsumerWidget {
  const HealthActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProfile = ref.watch(selectedProfileProvider);
    if (selectedProfile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(child: Text('No profile selected')),
      );
    }

    final historyState =
        ref.watch(historyNotifierProvider(selectedProfile.id));
    final reports = historyState.reports;
    final dailyCells = buildDetailedGrid(reports);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(dailyCells: dailyCells),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _LinkedHeatmap(dailyCells: dailyCells),
            ),

            const SizedBox(height: 20),
            _Legend(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Health Activity',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Linked heatmap — month labels + grid scroll together
// ─────────────────────────────────────────────────────────────────────────────

class _LinkedHeatmap extends StatefulWidget {
  final Map<String, HeatmapCell> dailyCells;

  const _LinkedHeatmap({required this.dailyCells});

  @override
  State<_LinkedHeatmap> createState() => _LinkedHeatmapState();
}

class _LinkedHeatmapState extends State<_LinkedHeatmap> {
  final ScrollController _scrollController = ScrollController();

  static const double _cellSize = 11;
  static const double _cellGap = 3;
  static const double _colWidth = _cellSize + _cellGap;
  static const double _dayLabelWidth = 28;
  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  late final List<MonthInfo> _months;
  late final DateTime _gridStart;
  late final DateTime _gridEnd;
  late final int _totalWeeks;
  late final List<_MonthSpan> _monthSpans;

  @override
  void initState() {
    super.initState();

    _months = getLast12Months();
    final months = _months;
    // Grid covers: first day of current month → last day of 12th month
    final start = DateTime(months.first.year, months.first.month, 1);
    final lastMonth = months.last;
    _gridEnd = DateTime(lastMonth.year, lastMonth.month + 1, 0);

    // Pad to Sunday for week alignment
    _gridStart = start.subtract(Duration(days: start.weekday % 7));
    final totalDays = _gridEnd.difference(_gridStart).inDays + 1;
    _totalWeeks = (totalDays / 7).ceil();
    _monthSpans = _buildMonthSpans(months);
  }

  List<_MonthSpan> _buildMonthSpans(List<MonthInfo> months) {
    // Build a set of valid months
    final validKeys = months.map((m) => '${m.year}-${m.month}').toSet();

    final spans = <_MonthSpan>[];
    int? currentMonth;
    int? currentYear;
    int spanStart = 0;

    for (int w = 0; w < _totalWeeks; w++) {
      final midWeek = _gridStart.add(Duration(days: w * 7 + 3));
      if (midWeek.month != currentMonth || midWeek.year != currentYear) {
        if (currentMonth != null && validKeys.contains('$currentYear-$currentMonth')) {
          spans.add(_MonthSpan(
            month: currentMonth,
            year: currentYear!,
            startWeek: spanStart,
            weekCount: w - spanStart,
          ));
        }
        currentMonth = midWeek.month;
        currentYear = midWeek.year;
        spanStart = w;
      }
    }
    if (currentMonth != null && validKeys.contains('$currentYear-$currentMonth')) {
      spans.add(_MonthSpan(
        month: currentMonth,
        year: currentYear!,
        startWeek: spanStart,
        weekCount: _totalWeeks - spanStart,
      ));
    }
    return spans;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = _totalWeeks * _colWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _dayLabelWidth + gridWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month labels
                Padding(
                  padding: EdgeInsets.only(left: _dayLabelWidth),
                  child: SizedBox(
                    height: 18,
                    child: Row(
                      children: _monthSpans.map((span) {
                        return SizedBox(
                          width: span.weekCount * _colWidth,
                          child: Text(
                            span.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Day labels + grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day-of-week labels
                    Column(
                      children: List.generate(7, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: _cellGap),
                        child: SizedBox(
                          height: _cellSize,
                          width: _dayLabelWidth,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _dayLabels[i],
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ),

                    // Grid columns (weeks)
                    ...List.generate(_totalWeeks, (weekIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(right: _cellGap),
                        child: Column(
                          children: List.generate(7, (dayIndex) {
                            final dayOffset = weekIndex * 7 + dayIndex;
                            final date = _gridStart.add(Duration(days: dayOffset));

                            // Skip dates outside the 12-month range
                            if (date.isBefore(DateTime(_months.first.year, _months.first.month, 1)) ||
                                date.isAfter(_gridEnd)) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: _cellGap),
                                child: SizedBox(width: _cellSize, height: _cellSize),
                              );
                            }

                            final now = DateTime.now();
                            // Future dates are always empty
                            final isFuture = date.isAfter(now);
                            final key = '${date.year}-${date.month}-${date.day}';
                            final cell = isFuture ? null : widget.dailyCells[key];
                            final level = cell?.level ?? HeatmapLevel.empty;

                            final delay = (weekIndex * 6).clamp(0, 300);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: _cellGap),
                              child: AnimatedHeatmapCell(
                                level: level,
                                size: _cellSize,
                                borderRadius: 3,
                                delayMs: delay,
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthSpan {
  final int month;
  final int year;
  final int startWeek;
  final int weekCount;

  static const _names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  _MonthSpan({
    required this.month,
    required this.year,
    required this.startWeek,
    required this.weekCount,
  });

  String get label => _names[month - 1];
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary row
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final Map<String, HeatmapCell> dailyCells;

  const _SummaryRow({required this.dailyCells});

  @override
  Widget build(BuildContext context) {
    final activeDays =
        dailyCells.values.where((c) => c.level != HeatmapLevel.empty).length;
    final totalDays = dailyCells.length;

    return Row(
      children: [
        _SummaryChip(
          label: 'Active Days',
          value: '$activeDays',
          icon: Icons.calendar_today_rounded,
        ),
        const SizedBox(width: 12),
        _SummaryChip(
          label: 'Period',
          value: '$totalDays days',
          icon: Icons.date_range_rounded,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Less',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _legendCell(HeatmapLevel.empty),
          _legendCell(HeatmapLevel.critical),
          _legendCell(HeatmapLevel.attention),
          _legendCell(HeatmapLevel.mild),
          _legendCell(HeatmapLevel.excellent),
          const SizedBox(width: 8),
          const Text('More',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _legendCell(HeatmapLevel level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: HeatmapCellWidget(level: level, size: 12, borderRadius: 3),
    );
  }
}
