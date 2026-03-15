import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../utils/heatmap_mapper.dart';
import 'health_heatmap_cell.dart';

/// Compact heatmap preview card for the Home screen.
/// 12 columns (months) x 5 rows (weeks). Tappable to open detail.
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
    final months = getLast12Months();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Health Activity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Grid
            LayoutBuilder(builder: (context, constraints) {
              final cellSize = ((constraints.maxWidth - 3.0 * 11) / 12).clamp(4.0, 12.0);

              return Column(
                children: [
                  // 5 rows x 12 columns
                  ...List.generate(5, (week) {
                    return Padding(
                      padding: EdgeInsets.only(top: week > 0 ? 2 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(12, (month) {
                          final index = month * 5 + week;
                          final level = index < cells.length
                              ? cells[index].level
                              : HeatmapLevel.empty;
                          return HeatmapCellWidget(
                            level: level,
                            size: cellSize,
                            borderRadius: 2,
                          );
                        }),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  // Month labels — show first, middle, last
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(months.first.label,
                          style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                      Text(months[6].label,
                          style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                      Text(months.last.label,
                          style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
