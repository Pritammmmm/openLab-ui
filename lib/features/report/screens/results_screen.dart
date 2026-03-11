import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../models/report_model.dart';
import '../models/parameter_model.dart';
import '../providers/report_provider.dart';
import '../widgets/comparison_card.dart';
import '../widgets/parameter_card.dart';
import '../widgets/summary_tab.dart';
import '../../../features/home/providers/home_provider.dart';

class ResultsScreen extends ConsumerWidget {
  final String reportId;

  const ResultsScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: reportAsync.when(
        data: (report) => _ResultsBody(report: report),
        loading: () => const AppLoading(message: 'Loading results...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load report',
          onRetry: () => ref.invalidate(reportDetailProvider(reportId)),
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  final ReportModel report;

  const _ResultsBody({required this.report});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: report.aiComparisonSummary != null ? 4 : 3,
      child: Column(
        children: [
          // Disclaimer banner
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   color: AppColors.yellowBg,
          //   child: Row(
          //     children: [
          //       const Icon(Icons.info_outline_rounded,
          //           size: 16, color: AppColors.yellow),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           'For informational purposes only. Consult your doctor for medical advice.',
          //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //                 color: AppColors.textSecondary,
          //                 fontSize: 11,
          //               ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Overall status card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        OverallStatusCircle(
                          status: report.overallStatus ?? 'green',
                          size: 56,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helpers.statusLabel(
                                    report.overallStatus ?? 'green'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppColors.trafficLightColor(
                                          report.overallStatus ?? 'green'),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Helpers.formatDate(
                                    report.reportDate ?? report.uploadDate),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (report.labName != null)
                                Text(
                                  report.labName!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        TrafficLightBadge(
                          status: 'green',
                          count: report.statusCounts.green,
                        ),
                        TrafficLightBadge(
                          status: 'yellow',
                          count: report.statusCounts.yellow,
                        ),
                        TrafficLightBadge(
                          status: 'red',
                          count: report.statusCounts.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab bar
          TabBar(
            tabs: [
              const Tab(text: 'Summary'),
              const Tab(text: 'Parameters'),
              if (report.aiComparisonSummary != null)
                const Tab(text: 'Compare'),
              const Tab(text: 'What To Do'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                SummaryTab(report: report),
                _ParametersTab(report: report),
                if (report.aiComparisonSummary != null)
                  _CompareTab(report: report),
                _WhatToDoTab(report: report),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParametersTab extends ConsumerWidget {
  final ReportModel report;

  const _ParametersTab({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get profile age
    final profiles = ref.watch(profilesProvider);
    final profileAge = profiles.whenOrNull(
      data: (list) {
        final profile = list.where((p) => p.id == report.profileId).firstOrNull;
        return profile?.age;
      },
    );

    final categories = report.parametersByCategory;
    final sortedKeys = categories.keys.toList()
      ..sort((a, b) {
        final aHasRed =
            categories[a]!.any((p) => p.trafficLight == 'red') ? 0 : 1;
        final bHasRed =
            categories[b]!.any((p) => p.trafficLight == 'red') ? 0 : 1;
        if (aHasRed != bHasRed) return aHasRed - bHasRed;
        final aHasYellow =
            categories[a]!.any((p) => p.trafficLight == 'yellow') ? 0 : 1;
        final bHasYellow =
            categories[b]!.any((p) => p.trafficLight == 'yellow') ? 0 : 1;
        return aHasYellow - bHasYellow;
      });

    // Sort params within each category: red first, yellow, green last
    int statusPriority(String light) => switch (light) {
          'red' => 0,
          'yellow' => 1,
          _ => 2,
        };

    final widgets = <Widget>[];
    for (final category in sortedKeys) {
      final params = List<ParameterModel>.from(categories[category]!)
        ..sort((a, b) =>
            statusPriority(a.trafficLight) - statusPriority(b.trafficLight));

      final redCount = params.where((p) => p.trafficLight == 'red').length;
      final yellowCount =
          params.where((p) => p.trafficLight == 'yellow').length;

      // Category header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.science_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (redCount > 0) ...[
                TrafficLightBadge(
                  status: 'red',
                  count: redCount,
                  fontSize: 10,
                ),
                const SizedBox(width: 4),
              ],
              if (yellowCount > 0)
                TrafficLightBadge(
                  status: 'yellow',
                  count: yellowCount,
                  fontSize: 10,
                ),
            ],
          ),
        ),
      );

      // Parameter cards
      for (final param in params) {
        widgets.add(ParameterCard(parameter: param, age: profileAge));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: widgets,
    );
  }
}

class _CompareTab extends StatelessWidget {
  final ReportModel report;

  const _CompareTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final improved = report.parameters
        .where((p) => p.comparison?.trend == 'improved')
        .toList();
    final declined = report.parameters
        .where((p) => p.comparison?.trend == 'declined')
        .toList();
    final stable = report.parameters
        .where((p) => p.comparison?.trend == 'stable')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (report.aiComparisonSummary != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                report.aiComparisonSummary!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (improved.isNotEmpty) ...[
          _SectionHeader(
            title: 'Improved',
            icon: Icons.trending_up_rounded,
            color: AppColors.green,
            count: improved.length,
          ),
          const SizedBox(height: 8),
          ...improved.map((p) => ComparisonCard(parameter: p)),
          const SizedBox(height: 16),
        ],
        if (declined.isNotEmpty) ...[
          _SectionHeader(
            title: 'Declined',
            icon: Icons.trending_down_rounded,
            color: AppColors.red,
            count: declined.length,
          ),
          const SizedBox(height: 8),
          ...declined.map((p) => ComparisonCard(parameter: p)),
          const SizedBox(height: 16),
        ],
        if (stable.isNotEmpty) ...[
          _SectionHeader(
            title: 'Stable',
            icon: Icons.trending_flat_rounded,
            color: AppColors.textMuted,
            count: stable.length,
          ),
          const SizedBox(height: 8),
          ...stable.map((p) => ComparisonCard(parameter: p)),
        ],
      ],
    );
  }
}

class _WhatToDoTab extends StatelessWidget {
  final ReportModel report;

  const _WhatToDoTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final redParams =
        report.parameters.where((p) => p.trafficLight == 'red').toList();
    final yellowParams =
        report.parameters.where((p) => p.trafficLight == 'yellow').toList();
    final greenParams =
        report.parameters.where((p) => p.trafficLight == 'green').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (redParams.isNotEmpty) ...[
          _SectionHeader(
            title: 'Needs Attention',
            icon: Icons.priority_high_rounded,
            color: AppColors.red,
            count: redParams.length,
          ),
          const SizedBox(height: 8),
          ...redParams.map((p) => _ActionCard(
                parameter: p,
                color: AppColors.red,
                bgColor: AppColors.redBg,
              )),
          const SizedBox(height: 16),
        ],
        if (yellowParams.isNotEmpty) ...[
          _SectionHeader(
            title: 'Keep an Eye On',
            icon: Icons.visibility_rounded,
            color: AppColors.yellow,
            count: yellowParams.length,
          ),
          const SizedBox(height: 8),
          ...yellowParams.map((p) => _ActionCard(
                parameter: p,
                color: AppColors.yellow,
                bgColor: AppColors.yellowBg,
              )),
          const SizedBox(height: 16),
        ],
        if (greenParams.isNotEmpty) ...[
          _SectionHeader(
            title: 'Things You\'re Doing Well',
            icon: Icons.check_circle_rounded,
            color: AppColors.green,
            count: greenParams.length,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${greenParams.length} parameters are in the normal range. Great job maintaining your health!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.green,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: greenParams
                        .map((p) => TrafficLightBadge(
                              status: 'green',
                              label: p.shortName ?? p.name,
                              fontSize: 11,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Reminder CTA
        Card(
          color: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Next Checkup Reminder',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      Text(
                        'We\'ll remind you when it\'s time for your next test',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final ParameterModel parameter;
  final Color color;
  final Color bgColor;

  const _ActionCard({
    required this.parameter,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    parameter.trafficLight == 'red'
                        ? Icons.warning_amber_rounded
                        : Icons.visibility_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    parameter.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TrafficLightBadge(
                  status: parameter.trafficLight,
                  label:
                      '${Helpers.formatNumber(parameter.value)} ${parameter.unit}',
                  fontSize: 12,
                ),
              ],
            ),
            if (parameter.aiExplanation != null) ...[
              const SizedBox(height: 10),
              Text(
                parameter.aiExplanation!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
