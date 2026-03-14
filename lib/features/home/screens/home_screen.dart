import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../../report/models/parameter_model.dart';
import '../../report/models/report_model.dart';
import '../providers/home_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/health_score_ring.dart';
import '../widgets/key_parameters_list.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/smart_advice_section.dart';
import '../../history/providers/history_provider.dart';
import '../../trends/utils/heatmap_mapper.dart';
import '../../trends/widgets/health_heatmap_preview.dart';
import '../../trends/providers/parameter_trend_provider.dart';
import '../../trends/widgets/sparkline_preview.dart';
import '../../../core/config/app_router.dart';

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final selectedProfile = ref.watch(selectedProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(profilesProvider);
            if (selectedProfile != null) {
              ref.invalidate(latestReportProvider(selectedProfile.id));
              ref.invalidate(latestFullReportProvider(selectedProfile.id));
              ref.invalidate(historyNotifierProvider(selectedProfile.id));
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _Header(user: user)),

              // Body
              if (selectedProfile == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: profilesAsync.when(
                    data: (_) => const _NoProfileState(),
                    loading: () => const AppLoading(),
                    error: (e, _) => AppErrorWidget(
                      message: 'Failed to load profiles',
                      onRetry: () => ref.invalidate(profilesProvider),
                    ),
                  ),
                )
              else
                _HomeBody(profileId: selectedProfile.id),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedProfile != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/upload'),
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Upload Report'),
              ),
            )
          : null,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final dynamic user;

  const _Header({this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ScaffoldWithNav.scaffoldKey.currentState?.openDrawer(),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      (user?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeGreeting(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Home Body — Sliver that handles loading / error / premium content
// ──────────────────────────────────────────────────────────────────────────────

class _HomeBody extends ConsumerWidget {
  final String profileId;

  const _HomeBody({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestReportProvider(profileId));

    return latestAsync.when(
      data: (summary) {
        if (summary == null) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(),
          );
        }

        final fullReport =
            ref.watch(latestFullReportProvider(profileId)).valueOrNull;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Health Score + Top Parameters Row ──
                if (summary.isCompleted) ...[
                  Builder(builder: (context) {
                    final counts = fullReport != null
                        ? StatusCounts(
                            green: fullReport.parameters.where((p) => p.trafficLight == 'green').length,
                            yellow: fullReport.parameters.where((p) => p.trafficLight == 'yellow').length,
                            red: fullReport.parameters.where((p) => p.trafficLight == 'red').length,
                          )
                        : summary.statusCounts;

                    final topGreenParams = fullReport != null
                        ? fullReport.parameters
                            .where((p) => p.trafficLight == 'green')
                            .take(3)
                            .toList()
                        : <ParameterModel>[];

                    final scoreCard = HealthScoreCard(
                      healthScore: summary.healthScore,
                      statusCounts: counts,
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        scoreCard,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 0; i < 3; i++) ...[
                                if (i > 0) const SizedBox(height: 8),
                                _TopParamBox(
                                  param: i < topGreenParams.length
                                      ? topGreenParams[i]
                                      : null,
                                  color: scoreCard.scoreColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Quick Stats ──
                  QuickStatsRow(
                    statusCounts: fullReport != null
                        ? StatusCounts(
                            green: fullReport.parameters.where((p) => p.trafficLight == 'green').length,
                            yellow: fullReport.parameters.where((p) => p.trafficLight == 'yellow').length,
                            red: fullReport.parameters.where((p) => p.trafficLight == 'red').length,
                          )
                        : summary.statusCounts,
                  ),
                ],

                // ── Health Activity + Placeholder Row ──
                if (summary.isCompleted) ...[
                  const SizedBox(height: 16),
                  _ActivityRow(profileId: profileId),
                ],

                // ── Parameters to Watch ──
                if (fullReport != null &&
                    fullReport.parameters.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  KeyParametersList(parameters: fullReport.parameters),
                ],

                // ── Smart Insights ──
                if (fullReport != null &&
                    fullReport.parameters.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  SmartAdviceSection(parameters: fullReport.parameters),
                ],

                // ── Latest Report Card ──
                const SizedBox(height: 28),
                _LatestReportCard(
                  reportId: summary.id,
                  labName: summary.labName,
                  reportDate: summary.reportDate ?? summary.uploadDate,
                  parameterCount: summary.parameterCount,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoading(message: 'Loading your health data...'),
      ),
      error: (e, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorWidget(
          message: 'Failed to load report',
          onRetry: () => ref.invalidate(latestReportProvider(profileId)),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Latest Report — tap to open full results
// ──────────────────────────────────────────────────────────────────────────────

class _LatestReportCard extends StatelessWidget {
  final String reportId;
  final String? labName;
  final DateTime reportDate;
  final int parameterCount;

  const _LatestReportCard({
    required this.reportId,
    this.labName,
    required this.reportDate,
    required this.parameterCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/results/$reportId'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Report',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Helpers.formatDate(reportDate)}${labName != null ? ' · $labName' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$parameterCount parameters analyzed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Activity Row — Health Activity heatmap preview + placeholder
// ──────────────────────────────────────────────────────────────────────────────

class _ActivityRow extends ConsumerWidget {
  final String profileId;

  const _ActivityRow({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider(profileId));
    final previewCells = buildPreviewGrid(historyState.reports);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Box 1: Health Activity heatmap preview
        Expanded(
          child: HealthHeatmapPreview(
            cells: previewCells,
            onTap: () => context.push('/health-activity'),
          ),
        ),
        const SizedBox(width: 12),
        // Box 2: Parameter trend sparkline
        Expanded(
          child: _SparklineBox(profileId: profileId),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sparkline Box — mini trend preview
// ──────────────────────────────────────────────────────────────────────────────

class _SparklineBox extends ConsumerWidget {
  final String profileId;

  const _SparklineBox({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(trendPreviewProvider(profileId));

    return trendAsync.when(
      data: (trend) => SparklinePreview(
        trend: trend,
        onTap: () => context.push('/parameter-trend'),
      ),
      loading: () => SparklinePreview(
        isLoading: true,
        onTap: () => context.push('/parameter-trend'),
      ),
      error: (_, __) => SparklinePreview(
        onTap: () => context.push('/parameter-trend'),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Top Parameter Box — shows a single green parameter
// ──────────────────────────────────────────────────────────────────────────────

class _TopParamBox extends StatelessWidget {
  final ParameterModel? param;
  final Color color;

  const _TopParamBox({this.param, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: param != null
          ? Row(
              children: [
                Icon(Icons.check_circle_rounded, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    param!.shortName ?? param!.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${param!.value % 1 == 0 ? param!.value.toInt() : param!.value.toStringAsFixed(1)} ${param!.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                '—',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// No Profile State
// ──────────────────────────────────────────────────────────────────────────────

class _NoProfileState extends StatelessWidget {
  const _NoProfileState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No profiles yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a profile to start tracking your health',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
