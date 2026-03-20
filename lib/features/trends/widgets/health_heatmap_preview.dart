import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../utils/heatmap_mapper.dart';
import 'health_heatmap_cell.dart';

/// Compact heatmap preview card for the Home screen.
/// 12 blocks — one per month, arranged in 2 rows of 6.
class HealthHeatmapPreview extends StatelessWidget {
  final List<HeatmapCell> cells;
  final VoidCallback? onTap;

  const HealthHeatmapPreview({
    super.key,
    required this.cells,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.grid_view_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Health Activity',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textMuted.withValues(alpha: 0.6)),
              ],
            ),
            const SizedBox(height: 10),

            // 12 blocks in 2 rows of 6
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                const gap = 5.0;
                final blockW = (constraints.maxWidth - gap * 5) / 6;
                final blockH = (constraints.maxHeight - gap - 16) / 2; // 2 rows + label space

                return Column(
                  children: [
                    _buildRow(0, 6, blockW, blockH, gap),
                    SizedBox(height: gap),
                    _buildRow(6, 12, blockW, blockH, gap),
                  ],
                );
              }),
            ),

            // Month labels
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (cells.isNotEmpty)
                  Text(cells.first.monthLabel,
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textMuted)),
                if (cells.length > 6)
                  Text(cells[6].monthLabel,
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textMuted)),
                if (cells.length > 11)
                  Text(cells.last.monthLabel,
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int start, int end, double w, double h, double gap) {
    return Row(
      children: List.generate(end - start, (i) {
        final index = start + i;
        final cell = index < cells.length ? cells[index] : null;

        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? gap : 0),
          child: GlowingHeatmapCell(
            level: cell?.level ?? HeatmapLevel.empty,
            isCurrentMonth: cell?.isCurrentMonth ?? false,
            width: w,
            height: h,
            borderRadius: 4,
          ),
        );
      }),
    );
  }
}
