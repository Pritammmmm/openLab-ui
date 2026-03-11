import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/last_report_card.dart';
import '../widgets/quick_stats_row.dart';

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
            }
          },
          child: CustomScrollView(
            slivers: [
              // Header: avatar + greeting + name
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? Text(
                                Helpers.firstNameFrom(user?.name ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Column(
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
                    ],
                  ),
                ),
              ),
              // Main content
              SliverFillRemaining(
                hasScrollBody: false,
                child: selectedProfile == null
                    ? profilesAsync.when(
                        data: (_) => const _NoProfileState(),
                        loading: () => const AppLoading(),
                        error: (e, _) => AppErrorWidget(
                          message: 'Failed to load profiles',
                          onRetry: () => ref.invalidate(profilesProvider),
                        ),
                      )
                    : _HomeContent(profileId: selectedProfile.id),
              ),
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

class _HomeContent extends ConsumerWidget {
  final String profileId;

  const _HomeContent({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestReportAsync = ref.watch(latestReportProvider(profileId));

    return latestReportAsync.when(
      data: (report) {
        if (report == null) {
          return const EmptyState();
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest Report',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              LastReportCard(report: report),
              const SizedBox(height: 16),
              if (report.isCompleted) ...[
                QuickStatsRow(statusCounts: report.statusCounts),
              ],
            ],
          ),
        );
      },
      loading: () => const AppLoading(message: 'Loading your reports...'),
      error: (e, _) => AppErrorWidget(
        message: 'Failed to load report',
        onRetry: () => ref.invalidate(latestReportProvider(profileId)),
      ),
    );
  }
}

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
