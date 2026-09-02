import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';

class WaterGlassIndicator extends StatelessWidget {
  final int current;
  final int goal;

  const WaterGlassIndicator({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(goal, (index) {
        final isFilled = index < current;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutBack,
          width: 36,
          height: 44,
          decoration: BoxDecoration(
            color: isFilled
                ? const Color(0xFF4FC3F7).withValues(alpha: 0.15)
                : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFilled
                  ? const Color(0xFF4FC3F7)
                  : AppColors.surfaceBorder,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.water_drop_rounded,
            size: 20,
            color: isFilled
                ? const Color(0xFF4FC3F7)
                : AppColors.textMuted.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
