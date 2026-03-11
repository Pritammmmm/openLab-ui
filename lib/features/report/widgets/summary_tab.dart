import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../models/report_model.dart';

class SummaryTab extends StatelessWidget {
  final ReportModel report;

  const SummaryTab({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall status message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.trafficLightBg(report.overallStatus ?? 'green'),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Row(
            children: [
              Icon(
                _statusIcon(report.overallStatus),
                color:
                    AppColors.trafficLightColor(report.overallStatus ?? 'green'),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Helpers.overallStatusMessage(report.overallStatus),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.trafficLightColor(
                            report.overallStatus ?? 'green'),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Summary
        if (report.aiSummary != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Summary',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report.aiSummary!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Report details
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Date',
                  value: Helpers.formatDate(
                      report.reportDate ?? report.uploadDate),
                ),
                if (report.labName != null)
                  _DetailRow(label: 'Lab', value: report.labName!),
                _DetailRow(
                  label: 'Parameters',
                  value: '${report.parameters.length} analyzed',
                ),
                _DetailRow(
                  label: 'Uploaded',
                  value: Helpers.formatRelativeDate(report.uploadDate),
                ),
              ],
            ),
          ),
        ),

        // Comparison strip
        if (report.aiComparisonSummary != null) ...[
          const SizedBox(height: 16),
          Card(
            color: AppColors.secondary.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows_rounded,
                      color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compared to Previous',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.secondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.aiComparisonSummary!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _statusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'green':
        return Icons.check_circle_rounded;
      case 'yellow':
        return Icons.warning_rounded;
      case 'red':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
