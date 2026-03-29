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
import '../../../core/widgets/isometric_icon.dart';
import '../../profile/models/profile_model.dart' show ProfileModel;
import '../../profile/providers/profile_provider.dart' show maxProfilesForPlan;
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../../core/widgets/premium_gate.dart';

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
              ref.invalidate(trendPreviewProvider(selectedProfile.id));
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              const SliverToBoxAdapter(child: _Header()),

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
      floatingActionButton: null,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header — shows greeting, profile avatar, and profile switcher dropdown
// ──────────────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final selectedProfile = ref.watch(selectedProfileProvider);
    final profiles = profilesAsync.valueOrNull ?? [];
    final hasMultipleProfiles = profiles.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                ScaffoldWithNav.scaffoldKey.currentState?.openDrawer(),
            child: _buildAvatar(user, selectedProfile),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeGreeting(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: hasMultipleProfiles
                      ? () => _showProfileSwitcher(
                            context, ref, profiles, selectedProfile)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          selectedProfile?.name ?? user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasMultipleProfiles) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic user, ProfileModel? profile) {
    final isSelf = profile == null || profile.relation == 'self';
    final hasPhoto = isSelf && user?.photoUrl != null;

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: hasPhoto ? NetworkImage(user!.photoUrl!) : null,
      child: !hasPhoto
          ? Text(
              profile?.initials ?? (user?.name ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }

  void _showProfileSwitcher(
    BuildContext context,
    WidgetRef ref,
    List<ProfileModel> profiles,
    ProfileModel? selected,
  ) {
    final user = ref.read(currentUserProvider);
    final maxAllowed = maxProfilesForPlan(user?.subscription.plan);

    ScaffoldWithNav.navBarVisible.value = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ProfileSwitcherSheet(
        profiles: profiles,
        selectedId: selected?.id,
        maxAllowed: maxAllowed,
        onSelect: (index) {
          ref.read(selectedProfileIndexProvider.notifier).state = index;
          Navigator.pop(ctx);
        },
        onManage: () {
          Navigator.pop(ctx);
          GoRouter.of(context).push('/settings/profiles');
        },
      ),
    ).whenComplete(() {
      ScaffoldWithNav.navBarVisible.value = true;
    });
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Profile Switcher Bottom Sheet
// ──────────────────────────────────────────────────────────────────────────────

class _ProfileSwitcherSheet extends StatelessWidget {
  final List<ProfileModel> profiles;
  final String? selectedId;
  final int maxAllowed;
  final ValueChanged<int> onSelect;
  final VoidCallback onManage;

  const _ProfileSwitcherSheet({
    required this.profiles,
    required this.selectedId,
    required this.maxAllowed,
    required this.onSelect,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                // Title row
                Row(
                  children: [
                    Text(
                      'Switch Profile',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${profiles.length}/$maxAllowed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile options in grouped card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: profiles.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        final isSelected = profile.id == selectedId;
                        return _ProfileOption(
                          profile: profile,
                          isSelected: isSelected,
                          onTap: () => onSelect(index),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Manage profiles button — pill style
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: onManage,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings_rounded,
                            size: 17, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Manage Profiles',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final ProfileModel profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.05)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [AppColors.primary, AppColors.primaryLight]
                        : [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.primary.withValues(alpha: 0.06),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.initials,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isDefault) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.yellow),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.relation[0].toUpperCase()}${profile.relation.substring(1)} · ${profile.reportCount} reports',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon3D(
              icon: Icons.description_rounded,
              size: 48,
              color: AppColors.primary,
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
    final previewCells = buildMonthlyGrid(historyState.reports);
    final activePlan = ref.watch(activePlanProvider);
    final isFree = activePlan == PlanTier.free;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Box 1: Health Activity heatmap preview
        Expanded(
          child: PremiumGate(
            requiredPlan: PlanTier.plus,
            blurChild: true,
            featureName: 'Health Activity',
            child: HealthHeatmapPreview(
              cells: previewCells,
              onTap: isFree ? null : () => context.push('/health-activity'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Box 2: Parameter trend sparkline
        Expanded(
          child: PremiumGate(
            requiredPlan: PlanTier.plus,
            blurChild: true,
            featureName: 'Trends',
            child: _SparklineBox(profileId: profileId),
          ),
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
    final historyState = ref.watch(historyNotifierProvider(profileId));
    final isUnlocked = historyState.reports.length >= 3;

    return trendAsync.when(
      data: (trend) => SparklinePreview(
        trend: isUnlocked ? trend : null,
        onTap: isUnlocked ? () => context.push('/parameter-trend') : null,
      ),
      loading: () => SparklinePreview(
        isLoading: isUnlocked,
        onTap: isUnlocked ? () => context.push('/parameter-trend') : null,
      ),
      error: (_, __) => SparklinePreview(
        onTap: isUnlocked ? () => context.push('/parameter-trend') : null,
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
            const IsometricIcon(
              icon: Icons.person_add_rounded,
              size: 80,
              color: AppColors.primary,
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
