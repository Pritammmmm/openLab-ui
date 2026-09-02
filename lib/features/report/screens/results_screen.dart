import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../core/widgets/skeleton_loaders.dart';
import '../models/report_model.dart';
import '../models/parameter_model.dart';
import '../providers/report_provider.dart';
import '../widgets/parameter_card.dart';
import '../widgets/comparison_card.dart';
import '../widgets/summary_tab.dart';
import '../../home/providers/home_provider.dart';

class ResultsScreen extends ConsumerWidget {
  final String reportId;

  const ResultsScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: reportAsync.when(
        data: (report) => _ResultsBody(report: report),
        loading: () => const ResultsScreenSkeleton(),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load report',
          onRetry: () => ref.invalidate(reportDetailProvider(reportId)),
        ),
      ),
    );
  }
}

// ─── Main body ─────────────────────────────────────────────────────────────

class _ResultsBody extends ConsumerStatefulWidget {
  final ReportModel report;

  const _ResultsBody({required this.report});

  @override
  ConsumerState<_ResultsBody> createState() => _ResultsBodyState();
}

class _ResultsBodyState extends ConsumerState<_ResultsBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final hasCompare = report.aiComparisonSummary != null;
    final tabCount = hasCompare ? 3 : 2;

    return DefaultTabController(
      length: tabCount,
      child: SafeArea(
        bottom: false,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    _NavButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.go('/'),
                    ),
                    const Expanded(
                      child: Text(
                        'Report',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryCtrl,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
                child: _HeroStatusCard(report: report),
              ),
            ),
          ],
          body: Column(
            children: [
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryCtrl,
                  curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  padding: const EdgeInsets.all(4),
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
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    splashFactory: NoSplash.splashFactory,
                    tabs: [
                      const Tab(text: 'Parameters', height: 36),
                      if (hasCompare) const Tab(text: 'Compare', height: 36),
                      const Tab(text: 'Summary', height: 36),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ParametersTab(report: report),
                    if (hasCompare) _CompareTab(report: report),
                    SummaryTab(report: report),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Navigation button ────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

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
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─── Hero status card ─────────────────────────────────────────────────────

class _HeroStatusCard extends StatelessWidget {
  final ReportModel report;

  const _HeroStatusCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final status = report.overallStatus ?? 'green';
    final color = AppColors.trafficLightColor(status);
    final score = report.healthScore?.score;
    final total = report.statusCounts.green +
        report.statusCounts.yellow +
        report.statusCounts.red;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F5FF), Color(0xFFF2F0FF), Color(0xFFEEF3FF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  if (score != null)
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CustomPaint(
                        painter: _ScoreRingPainter(
                          score: score,
                          color: color,
                        ),
                        child: Center(
                          child: Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: color,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForStatus(status),
                        color: color,
                        size: 28,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Helpers.statusLabel(status),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            Helpers.formatDate(
                                report.reportDate ?? report.uploadDate),
                            if (report.labName != null) report.labName!,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (score != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            report.healthScore!.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      if (report.statusCounts.green > 0)
                        Expanded(
                          flex: report.statusCounts.green,
                          child: Container(color: AppColors.green),
                        ),
                      if (report.statusCounts.yellow > 0)
                        Expanded(
                          flex: report.statusCounts.yellow,
                          child: Container(
                            margin: EdgeInsets.only(
                                left:
                                    report.statusCounts.green > 0 ? 2 : 0),
                            color: AppColors.yellow,
                          ),
                        ),
                      if (report.statusCounts.red > 0)
                        Expanded(
                          flex: report.statusCounts.red,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: (report.statusCounts.green > 0 ||
                                        report.statusCounts.yellow > 0)
                                    ? 2
                                    : 0),
                            color: AppColors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _CountChip(
                    icon: Icons.check_circle_rounded,
                    count: report.statusCounts.green,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 8),
                  _CountChip(
                    icon: Icons.warning_rounded,
                    count: report.statusCounts.yellow,
                    color: AppColors.yellow,
                  ),
                  const SizedBox(width: 8),
                  _CountChip(
                    icon: Icons.error_rounded,
                    count: report.statusCounts.red,
                    color: AppColors.red,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$total tested',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForStatus(String status) {
    return switch (status.toLowerCase()) {
      'green' || 'normal' => Icons.check_rounded,
      'yellow' || 'borderline' => Icons.warning_amber_rounded,
      'red' || 'abnormal' || 'attention' => Icons.priority_high_rounded,
      _ => Icons.help_outline_rounded,
    };
  }
}

// ─── Score ring painter ───────────────────────────────────────────────────

class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color color;

  _ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.0;

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progress = (score / 100).clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * progress;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      score != old.score || color != old.color;
}

// ─── Count chip ───────────────────────────────────────────────────────────

class _CountChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _CountChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Parameters tab ───────────────────────────────────────────────────────

class _ParametersTab extends ConsumerWidget {
  final ReportModel report;

  const _ParametersTab({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final profileAge = profiles.whenOrNull(
      data: (list) {
        final profile =
            list.where((p) => p.id == report.profileId).firstOrNull;
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

      widgets.add(_CategoryHeader(
        title: category,
        redCount: redCount,
        yellowCount: yellowCount,
        totalCount: params.length,
      ));

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                for (int i = 0; i < params.length; i++) ...[
                  ParameterCard(parameter: params[i], age: profileAge),
                  if (i < params.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.divider.withValues(alpha: 0.5),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    widgets.add(const Padding(
      padding: EdgeInsets.only(top: 4),
      child: MedicalDisclaimer(compact: true),
    ));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: widgets,
    );
  }
}

// ─── Category header ──────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final String title;
  final int redCount;
  final int yellowCount;
  final int totalCount;

  const _CategoryHeader({
    required this.title,
    required this.redCount,
    required this.yellowCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.science_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '$totalCount parameters',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (redCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_rounded,
                      size: 11, color: AppColors.red),
                  const SizedBox(width: 3),
                  Text(
                    '$redCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          if (yellowCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_rounded,
                      size: 11, color: AppColors.yellow),
                  const SizedBox(width: 3),
                  Text(
                    '$yellowCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.yellow,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Compare tab ──────────────────────────────────────────────────────────

class _CompareTab extends StatefulWidget {
  final ReportModel report;

  const _CompareTab({required this.report});

  @override
  State<_CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends State<_CompareTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Widget _staggered({required double start, required Widget child}) {
    final end = (start + 0.35).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _animCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, ch) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - anim.value)),
          child: ch,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final improved = report.parameters
        .where((p) => p.comparison?.trend == 'improved')
        .toList();
    final declined = report.parameters
        .where((p) => p.comparison?.trend == 'declined')
        .toList();
    final stable = report.parameters
        .where((p) => p.comparison?.trend == 'stable')
        .toList();
    final totalCompared = improved.length + declined.length + stable.length;

    if (totalCompared == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.compare_arrows_rounded,
                    size: 32,
                    color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 16),
              const Text(
                'No comparison data',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload more reports to see how\nyour values change over time.',
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

    double delay = 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // Summary stats row
        _staggered(
          start: delay,
          child: _CompareSummaryRow(
            improved: improved.length,
            declined: declined.length,
            stable: stable.length,
          ),
        ),
        const SizedBox(height: 16),

        // AI comparison summary
        if (report.aiComparisonSummary != null) ...[
          _staggered(
            start: delay += 0.08,
            child: _AiComparisonCard(summary: report.aiComparisonSummary!),
          ),
          const SizedBox(height: 20),
        ],

        // Improved section
        ..._buildSection(
          title: 'Improved',
          icon: Icons.trending_up_rounded,
          color: AppColors.green,
          params: improved,
          delay: delay += 0.08,
        ),

        // Declined section
        ..._buildSection(
          title: 'Needs Attention',
          icon: Icons.trending_down_rounded,
          color: AppColors.red,
          params: declined,
          delay: delay += 0.1,
        ),

        // Stable section
        ..._buildSection(
          title: 'Stable',
          icon: Icons.trending_flat_rounded,
          color: AppColors.textMuted,
          params: stable,
          delay: delay += 0.1,
        ),
      ],
    );
  }

  List<Widget> _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<ParameterModel> params,
    required double delay,
  }) {
    if (params.isEmpty) return [];
    return [
      _staggered(
        start: delay,
        child: _TrendSectionHeader(
          title: title,
          icon: icon,
          color: color,
          count: params.length,
        ),
      ),
      const SizedBox(height: 10),
      _staggered(
        start: (delay + 0.06).clamp(0.0, 1.0),
        child: _TrendGroup(parameters: params, sectionColor: color),
      ),
      const SizedBox(height: 20),
    ];
  }
}

// ─── Compare summary row ──────────────────────────────────────────────────

class _CompareSummaryRow extends StatelessWidget {
  final int improved;
  final int declined;
  final int stable;

  const _CompareSummaryRow({
    required this.improved,
    required this.declined,
    required this.stable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F5FF), Color(0xFFF2F0FF), Color(0xFFEEF3FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          _SummaryStatChip(
            icon: Icons.trending_up_rounded,
            label: 'Improved',
            count: improved,
            color: AppColors.green,
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          _SummaryStatChip(
            icon: Icons.trending_down_rounded,
            label: 'Declined',
            count: declined,
            color: AppColors.red,
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          _SummaryStatChip(
            icon: Icons.trending_flat_rounded,
            label: 'Stable',
            count: stable,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _SummaryStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _SummaryStatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI comparison card ───────────────────────────────────────────────────

class _AiComparisonCard extends StatelessWidget {
  final String summary;

  const _AiComparisonCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Comparison',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trend section header ─────────────────────────────────────────────────

class _TrendSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  const _TrendSectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Trend group ──────────────────────────────────────────────────────────

class _TrendGroup extends StatelessWidget {
  final List<ParameterModel> parameters;
  final Color sectionColor;

  const _TrendGroup({
    required this.parameters,
    required this.sectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top accent strip
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    sectionColor.withValues(alpha: 0.6),
                    sectionColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < parameters.length; i++) ...[
              ComparisonCard(parameter: parameters[i]),
              if (i < parameters.length - 1)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 16,
                  color: AppColors.divider.withValues(alpha: 0.4),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
