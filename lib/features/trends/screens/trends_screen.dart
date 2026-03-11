import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../home/providers/home_provider.dart';
import '../../home/widgets/profile_switcher.dart';
import '../providers/trends_provider.dart';
import '../widgets/trend_chart.dart';

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  static const _categories = [
    null,
    'CBC',
    'Blood Sugar',
    'Lipid Profile',
    'Liver',
    'Kidney',
    'Thyroid',
  ];

  static const _categoryLabels = [
    'All',
    'CBC',
    'Blood Sugar',
    'Lipid',
    'Liver',
    'Kidney',
    'Thyroid',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final selectedProfile = ref.watch(selectedProfileProvider);
    final selectedCategory = ref.watch(selectedTrendCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Trends')),
      body: Column(
        children: [
          // Profile switcher
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

          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categoryLabels[index]),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedTrendCategoryProvider.notifier).state =
                          cat;
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Chart content
          Expanded(
            child: selectedProfile == null
                ? const Center(child: Text('Select a profile'))
                : _TrendsContent(profileId: selectedProfile.id),
          ),
        ],
      ),
    );
  }
}

class _TrendsContent extends ConsumerWidget {
  final String profileId;

  const _TrendsContent({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(trendsDataProvider(profileId));

    return trendsAsync.when(
      data: (trends) {
        if (trends.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart_rounded,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No trend data yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload at least 2 reports to see trends over time',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trends.length,
          itemBuilder: (context, index) {
            final trend = trends[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trend.name,
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (trend.category != null)
                            Text(
                              trend.category!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: TrendChart(
                          dataPoints: trend.dataPoints,
                          unit: trend.unit,
                          refMin: trend.refMin,
                          refMax: trend.refMax,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const AppLoading(message: 'Loading trends...'),
      error: (e, _) => AppErrorWidget(
        message: 'Failed to load trends',
        onRetry: () => ref.invalidate(trendsDataProvider(profileId)),
      ),
    );
  }
}
