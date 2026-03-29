import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../home/providers/home_provider.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/report_history_card.dart';
import '../../home/widgets/profile_switcher.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final selectedProfile = ref.watch(selectedProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text('History'),
      ),
      body: Column(
        children: [
          profilesAsync.when(
            data: (profiles) => ProfileSwitcher(
              profiles: profiles,
              selectedIndex: ref.watch(selectedProfileIndexProvider),
              onSelected: (index) {
                ref.read(selectedProfileIndexProvider.notifier).state = index;
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: selectedProfile == null
                ? const Center(
                    child: Text('Select a profile to view history'))
                : _HistoryList(profileId: selectedProfile.id),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  final String profileId;

  const _HistoryList({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider(profileId));
    final activePlan = ref.watch(activePlanProvider);
    final isFree = activePlan == PlanTier.free;

    if (historyState.error != null && historyState.reports.isEmpty) {
      return AppErrorWidget(
        message: 'Failed to load history',
        onRetry: () =>
            ref.read(historyNotifierProvider(profileId).notifier).refresh(),
      );
    }

    if (historyState.isLoading && historyState.reports.isEmpty) {
      return const AppLoading(message: 'Loading your reports...');
    }

    if (historyState.reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded,
                  size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'No reports yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your first blood test report to see it here',
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(historyNotifierProvider(profileId).notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyState.reports.length +
            (isFree && historyState.reports.isNotEmpty ? 1 : 0) +
            (historyState.hasMore && !isFree ? 1 : 0),
        itemBuilder: (context, index) {
          // Report cards
          if (index < historyState.reports.length) {
            final report = historyState.reports[index];
            return ReportHistoryCard(
              report: report,
              onTap: () => context.push('/results/${report.id}'),
            );
          }

          // Free user: upgrade banner after last visible report
          if (isFree) {
            return _HistoryUpgradeBanner();
          }

          // Paid user: loading indicator for pagination
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryUpgradeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            'See your full report history',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upgrade to Plus to access all your past reports and track changes over time.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Upgrade to Plus',
              icon: Icons.star_rounded,
              onPressed: () => GoRouter.of(context).push('/pricing'),
            ),
          ),
        ],
      ),
    );
  }
}
