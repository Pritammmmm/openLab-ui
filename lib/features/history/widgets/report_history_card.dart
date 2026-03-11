import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../../report/models/report_summary_model.dart';

class ReportHistoryCard extends StatelessWidget {
  final ReportSummaryModel report;
  final VoidCallback? onTap;

  const ReportHistoryCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date column
              Column(
                children: [
                  Text(
                    _dayOfMonth(report.reportDate ?? report.uploadDate),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    _monthYear(report.reportDate ?? report.uploadDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Vertical divider
              Container(
                width: 2,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.trafficLightColor(
                      report.overallStatus ?? 'green'),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.labName ?? 'Blood Test Report',
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        OverallStatusCircle(
                          status: report.overallStatus ?? 'green',
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        TrafficLightBadge(
                          status: 'green',
                          count: report.statusCounts.green,
                          fontSize: 10,
                        ),
                        TrafficLightBadge(
                          status: 'yellow',
                          count: report.statusCounts.yellow,
                          fontSize: 10,
                        ),
                        TrafficLightBadge(
                          status: 'red',
                          count: report.statusCounts.red,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayOfMonth(DateTime date) => date.day.toString();

  String _monthYear(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
