import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/skeleton_loaders.dart';
import '../../home/providers/home_provider.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/report_history_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProfile = ref.watch(selectedProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: selectedProfile == null
          ? const _NoProfileState()
          : _HistoryBody(profileId: selectedProfile.id, profileName: selectedProfile.name),
    );
  }
}

// ─── Main body ─────────────────────────────────────────────────────────────

class _HistoryBody extends ConsumerStatefulWidget {
  final String profileId;
  final String profileName;

  const _HistoryBody({required this.profileId, required this.profileName});

  @override
  ConsumerState<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends ConsumerState<_HistoryBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(historyNotifierProvider(widget.profileId));
    final activePlan = ref.read(activePlanProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        state.hasMore &&
        !state.isLoading &&
        activePlan != PlanTier.free) {
      ref.read(historyNotifierProvider(widget.profileId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState =
        ref.watch(historyNotifierProvider(widget.profileId));
    final activePlan = ref.watch(activePlanProvider);
    final isFree = activePlan == PlanTier.free;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'History',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.profileName}\'s reports',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HeaderAction(
                        icon: Icons.upload_file_rounded,
                        onTap: () => context.push('/upload'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // Summary bar
          if (historyState.reports.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _entryCtrl, curve: Curves.easeOut),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: _SummaryBar(reports: historyState.reports),
                ),
              ),
            ),

          // Content
          if (historyState.error != null && historyState.reports.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorWidget(
                message: 'Failed to load history',
                onRetry: () => ref
                    .read(historyNotifierProvider(widget.profileId).notifier)
                    .refresh(),
              ),
            )
          else if (historyState.isLoading && historyState.reports.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: HistoryScreenSkeleton(),
            )
          else if (historyState.reports.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                onUpload: () => context.push('/upload'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reports = historyState.reports;

                    if (index < reports.length) {
                      final delay = (index / 8).clamp(0.0, 1.0);
                      final itemAnim = CurvedAnimation(
                        parent: _entryCtrl,
                        curve: Interval(
                          delay,
                          (delay + 0.5).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      return AnimatedBuilder(
                        animation: itemAnim,
                        builder: (context, child) => Opacity(
                          opacity: itemAnim.value,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - itemAnim.value)),
                            child: child,
                          ),
                        ),
                        child: ReportHistoryCard(
                          report: reports[index],
                          onTap: () =>
                              context.push('/results/${reports[index].id}'),
                        ),
                      );
                    }

                    // Upgrade banner for free users
                    if (isFree) {
                      return const _UpgradeBanner();
                    }

                    // Loading more indicator
                    if (historyState.hasMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                        ),
                      );
                    }

                    return null;
                  },
                  childCount: historyState.reports.length +
                      (isFree && historyState.reports.isNotEmpty ? 1 : 0) +
                      (historyState.hasMore && !isFree ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Header action button ──────────────────────────────────────────────────

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

// ─── Summary bar ───────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final List reports;

  const _SummaryBar({required this.reports});

  @override
  Widget build(BuildContext context) {
    int totalGreen = 0, totalYellow = 0, totalRed = 0;
    for (final r in reports) {
      totalGreen += r.statusCounts.green as int;
      totalYellow += r.statusCounts.yellow as int;
      totalRed += r.statusCounts.red as int;
    }
    final total = totalGreen + totalYellow + totalRed;
    final greenPct = total > 0 ? (totalGreen / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F2FF), Color(0xFFEEF3FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          _SummaryChip(
            label: 'Reports',
            value: '${reports.length}',
            color: AppColors.primary,
          ),
          Container(
              width: 1, height: 28, color: AppColors.primary.withValues(alpha: 0.1)),
          _SummaryChip(
            label: 'Normal',
            value: '$greenPct%',
            color: AppColors.green,
          ),
          Container(
              width: 1, height: 28, color: AppColors.primary.withValues(alpha: 0.1)),
          _SummaryChip(
            label: 'Attention',
            value: '$totalYellow',
            color: AppColors.yellow,
          ),
          Container(
              width: 1, height: 28, color: AppColors.primary.withValues(alpha: 0.1)),
          _SummaryChip(
            label: 'Abnormal',
            value: '$totalRed',
            color: AppColors.red,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.0,
              )),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              )),
        ],
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.04),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.science_rounded,
                size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No reports yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first blood test report\nto start tracking your health.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: const Text('Upload Report',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── No profile state ──────────────────────────────────────────────────────

class _NoProfileState extends StatelessWidget {
  const _NoProfileState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded,
                size: 56, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No profile selected',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a profile from the home screen to view report history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Upgrade banner ────────────────────────────────────────────────────────

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F5FF), Color(0xFFF0ECFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_open_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 14),
          const Text(
            'Unlock full history',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upgrade to Plus to access all past reports and track changes over time.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => context.push('/pricing'),
              icon: const Icon(Icons.star_rounded, size: 18),
              label: const Text('Upgrade to Plus',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
