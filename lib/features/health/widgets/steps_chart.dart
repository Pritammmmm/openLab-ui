import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../models/health_data.dart';

class StepsBarChart extends StatefulWidget {
  final List<DailySteps> data;
  final int goal;

  const StepsBarChart({
    super.key,
    required this.data,
    required this.goal,
  });

  @override
  State<StepsBarChart> createState() => _StepsBarChartState();
}

class _StepsBarChartState extends State<StepsBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxSteps = widget.data
        .fold<int>(widget.goal, (max, d) => d.steps > max ? d.steps : max);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.data.map((day) {
              final heightFraction =
                  (day.steps / maxSteps * _controller.value).clamp(0.0, 1.0);
              final isToday = day == widget.data.last;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: heightFraction,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.day,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.w400,
                          color: isToday
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
