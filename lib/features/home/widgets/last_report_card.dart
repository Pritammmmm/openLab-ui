import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../../report/models/report_summary_model.dart';

class LastReportCard extends StatelessWidget {
  final ReportSummaryModel report;

  const LastReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/results/${report.id}'),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OverallStatusCircle(
                    status: report.overallStatus ?? 'green',
                    size: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Helpers.formatDate(
                              report.reportDate ?? report.uploadDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (report.labName != null)
                          Text(
                            report.labName!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    Helpers.statusLabel(report.overallStatus ?? 'green'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.trafficLightColor(
                              report.overallStatus ?? 'green'),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  TrafficLightBadge(
                    status: 'green',
                    count: report.statusCounts.green,
                    fontSize: 12,
                  ),
                  TrafficLightBadge(
                    status: 'yellow',
                    count: report.statusCounts.yellow,
                    fontSize: 12,
                  ),
                  TrafficLightBadge(
                    status: 'red',
                    count: report.statusCounts.red,
                    fontSize: 12,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Full Report',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
