import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
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
    final date = report.reportDate ?? report.uploadDate;
    final status = report.overallStatus ?? 'green';
    final statusColor = AppColors.trafficLightColor(status);
    final score = report.healthScore?.score;
    final total =
        report.statusCounts.green +
        report.statusCounts.yellow +
        report.statusCounts.red;
    final isProcessing = report.status == 'processing';
    final isFailed = report.status == 'failed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        child: Column(
          children: [
            // Color accent strip
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.7),
                    statusColor.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date block
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _monthAbbr(date.month),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '${date.year}',
                          style: TextStyle(
                            fontSize: 9,
                            color: statusColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

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
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isProcessing)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: AppColors.yellow,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text('Processing',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.yellow,
                                        )),
                                  ],
                                ),
                              ),
                            if (isFailed)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline_rounded,
                                        size: 10, color: AppColors.red),
                                    const SizedBox(width: 4),
                                    const Text('Failed',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.red,
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Parameter count
                        if (total > 0)
                          Text(
                            '$total parameters tested',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          )
                        else if (isFailed)
                          const Text(
                            'Could not process this report',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          )
                        else if (isProcessing)
                          const Text(
                            'Analysing your report...',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Status badges row
                        Row(
                          children: [
                            if (report.statusCounts.green > 0)
                              _StatusChip(
                                count: report.statusCounts.green,
                                color: AppColors.green,
                                icon: Icons.check_circle_rounded,
                              ),
                            if (report.statusCounts.yellow > 0) ...[
                              const SizedBox(width: 6),
                              _StatusChip(
                                count: report.statusCounts.yellow,
                                color: AppColors.yellow,
                                icon: Icons.warning_rounded,
                              ),
                            ],
                            if (report.statusCounts.red > 0) ...[
                              const SizedBox(width: 6),
                              _StatusChip(
                                count: report.statusCounts.red,
                                color: AppColors.red,
                                icon: Icons.error_rounded,
                              ),
                            ],
                            const Spacer(),

                            // Health score
                            if (score != null && !isProcessing)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(status),
                                        size: 13, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$score',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _monthAbbr(int month) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return m[month - 1];
  }

  static IconData _statusIcon(String status) {
    return switch (status.toLowerCase()) {
      'green' || 'normal' => Icons.check_rounded,
      'yellow' || 'borderline' => Icons.warning_amber_rounded,
      'red' || 'abnormal' || 'attention' => Icons.priority_high_rounded,
      _ => Icons.help_outline_rounded,
    };
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
