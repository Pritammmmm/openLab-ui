import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../home/providers/home_provider.dart';
import '../../report/models/parameter_model.dart';
import '../data/trends_repository.dart';
import '../providers/parameter_trend_provider.dart';
import '../widgets/trend_chart.dart';

class ParameterTrendScreen extends ConsumerStatefulWidget {
  const ParameterTrendScreen({super.key});

  @override
  ConsumerState<ParameterTrendScreen> createState() =>
      _ParameterTrendScreenState();
}

class _ParameterTrendScreenState extends ConsumerState<ParameterTrendScreen> {
  @override
  void dispose() {
    // Reset selection when leaving
    Future.microtask(() {
      ref.read(selectedDetailParameterProvider.notifier).state = null;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProfile = ref.watch(selectedProfileProvider);
    if (selectedProfile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: Text('No profile selected')),
      );
    }

    final profileId = selectedProfile.id;
    final availableParams = ref.watch(availableParametersProvider(profileId));
    final selectedName = ref.watch(selectedDetailParameterProvider);
    final critical = ref.watch(mostCriticalParameterProvider(profileId));
    final activeName = selectedName ?? critical?.name;
    final trendAsync = ref.watch(trendDetailProvider(profileId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parameter selector
            _ParameterSelector(
              parameters: availableParams,
              selectedName: activeName,
              onSelected: (name) {
                ref.read(selectedDetailParameterProvider.notifier).state = name;
              },
            ),
            const SizedBox(height: 20),

            // Chart
            trendAsync.when(
              data: (trend) {
                if (trend == null || trend.dataPoints.isEmpty) {
                  return _EmptyState();
                }
                return _TrendContent(trend: trend);
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 80),
                child: AppLoading(message: 'Loading trend data...'),
              ),
              error: (e, _) => AppErrorWidget(
                message: 'Failed to load trend',
                onRetry: () =>
                    ref.invalidate(trendDetailProvider(profileId)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Parameter Trend',
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
// Parameter Selector — tap to show dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _ParameterSelector extends StatelessWidget {
  final List<ParameterModel> parameters;
  final String? selectedName;
  final ValueChanged<String> onSelected;

  const _ParameterSelector({
    required this.parameters,
    this.selectedName,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.science_rounded, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedName ?? 'Select parameter',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 22, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    // Group parameters by category
    final grouped = <String, List<ParameterModel>>{};
    for (final p in parameters) {
      final cat = p.category ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(p);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Parameter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        ...entry.value.map((p) {
                          final isActive = p.name == selectedName;
                          return ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            selected: isActive,
                            selectedTileColor: AppColors.textPrimary.withValues(alpha: 0.06),
                            leading: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.trafficLightColor(p.trafficLight),
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: Text(
                              '${_formatVal(p.value)} ${p.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            onTap: () {
                              onSelected(p.name);
                              Navigator.of(ctx).pop();
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatVal(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trend Content — chart + stats
// ─────────────────────────────────────────────────────────────────────────────

class _TrendContent extends StatelessWidget {
  final TrendParameter trend;

  const _TrendContent({required this.trend});

  @override
  Widget build(BuildContext context) {
    final points = trend.dataPoints;
    final latest = points.last;
    final previous = points.length >= 2 ? points[points.length - 2] : null;

    double? changePct;
    if (previous != null && previous.value != 0) {
      changePct = ((latest.value - previous.value) / previous.value) * 100;
    }

    return Column(
      children: [
        // Chart card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trend.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (trend.category != null) ...[
                const SizedBox(height: 2),
                Text(
                  trend.category!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: TrendChart(
                  dataPoints: points,
                  unit: trend.unit,
                  refMin: trend.refMin,
                  refMax: trend.refMax,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            _StatCard(
              label: 'Current',
              value: _fmt(latest.value),
              unit: trend.unit,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Previous',
              value: previous != null ? _fmt(previous.value) : '—',
              unit: previous != null ? trend.unit : '',
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Change',
              value: changePct != null
                  ? '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(1)}%'
                  : '—',
              unit: '',
              color: changePct != null
                  ? (changePct >= 0 ? AppColors.green : AppColors.red)
                  : AppColors.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Reference range
        if (trend.refMin != null || trend.refMax != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                const Text(
                  'Reference Range',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_fmt(trend.refMin ?? 0)} – ${_fmt(trend.refMax ?? 0)} ${trend.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

        // Timeline
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...points.reversed.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.trafficLightColor(p.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            Helpers.formatDate(p.date),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Text(
                          '${_fmt(p.value)} ${trend.unit}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Card
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            if (unit.isNotEmpty)
              Text(unit,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 56, color: AppColors.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No trend data',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload at least 3 reports to see\nparameter trends over time',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
