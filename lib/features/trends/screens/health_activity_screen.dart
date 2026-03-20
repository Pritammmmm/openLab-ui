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
    final cells = buildMonthlyGrid(historyState.reports);
    final activeDays =
        cells.where((c) => c.level != HeatmapLevel.empty).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary chips
            Row(
              children: [
                _SummaryChip(
                  label: 'Active Months',
                  value: '$activeDays',
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(width: 12),
                _SummaryChip(
                  label: 'Period',
                  value: '12 months',
                  icon: Icons.date_range_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly grid — 3 columns x 4 rows
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
              child: Column(
                children: List.generate(4, (row) {
                  return Padding(
                    padding: EdgeInsets.only(top: row > 0 ? 10 : 0),
                    child: Row(
                      children: List.generate(3, (col) {
                        final index = row * 3 + col;
                        if (index >= cells.length) {
                          return const Expanded(child: SizedBox.shrink());
                        }
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: col > 0 ? 10 : 0),
                            child: _MonthCard(cell: cells[index]),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Legend
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
// Month Card — a single month block with label and score
// ─────────────────────────────────────────────────────────────────────────────

class _MonthCard extends StatefulWidget {
  final HeatmapCell cell;

  const _MonthCard({required this.cell});

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  bool get _shouldPulse =>
      widget.cell.isCurrentMonth && widget.cell.level != HeatmapLevel.empty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (_shouldPulse) {
      _controller.repeat(reverse: true);
    }
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = HeatmapColors.fromLevel(widget.cell.level);
    final isActive = widget.cell.level != HeatmapLevel.empty;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final t = _shouldPulse ? _glow.value : 0.0;
        return Container(
          height: 72,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(
                          alpha: _shouldPulse ? 0.25 + t * 0.35 : 0.35),
                      blurRadius: _shouldPulse ? 4 + t * 10 : 6,
                      spreadRadius: _shouldPulse ? t * 3 : 1,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.cell.monthLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textMuted,
            ),
          ),
          if (isActive)
            Text(
              '${widget.cell.score}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          else
            Text(
              '—',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Chip
// ─────────────────────────────────────────────────────────────────────────────

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
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _legendCell(HeatmapLevel.empty),
          _legendCell(HeatmapLevel.low),
          _legendCell(HeatmapLevel.medium),
          _legendCell(HeatmapLevel.high),
          _legendCell(HeatmapLevel.excellent),
          const SizedBox(width: 8),
          const Text('More',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
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
