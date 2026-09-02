import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_theme.dart';

// ─── Base shimmer bone ───────────────────────────────────────────────────────

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bone({
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

Widget _shimmerWrap({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    child: child,
  );
}

// ─── Home Screen Skeleton ────────────────────────────────────────────────────

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health score + spike params row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score ring placeholder
                const _Bone(width: 140, height: 170, radius: 16),
                const SizedBox(width: 12),
                // Spike param boxes
                Expanded(
                  child: Column(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: EdgeInsets.only(top: i > 0 ? 8 : 0),
                        child: const _Bone(height: 50, radius: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Quick stats row
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                    child: const _Bone(height: 64, radius: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Activity row (2 boxes)
            Row(
              children: [
                const Expanded(child: _Bone(height: 120, radius: 12)),
                const SizedBox(width: 12),
                const Expanded(child: _Bone(height: 120, radius: 12)),
              ],
            ),
            const SizedBox(height: 28),
            // Parameters to watch header
            const _Bone(width: 160, height: 20),
            const SizedBox(height: 12),
            // Parameter cards
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: const _Bone(height: 72, radius: 14),
              ),
            ),
            const SizedBox(height: 20),
            // Latest report card
            const _Bone(height: 88, radius: 12),
          ],
        ),
      ),
    );
  }
}

// ─── History Screen Skeleton ─────────────────────────────────────────────────

class HistoryScreenSkeleton extends StatelessWidget {
  const HistoryScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const _Bone(width: 44, height: 44, radius: 12),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Bone(width: 120, height: 14),
                          SizedBox(height: 8),
                          _Bone(width: 180, height: 12),
                          SizedBox(height: 6),
                          _Bone(width: 80, height: 10),
                        ],
                      ),
                    ),
                    const _Bone(width: 24, height: 24, radius: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Results Screen Skeleton ─────────────────────────────────────────────────

class ResultsScreenSkeleton extends StatelessWidget {
  const ResultsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top status card
            const _Bone(height: 140, radius: 16),
            const SizedBox(height: 16),
            // Tab bar placeholder
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                    child: const _Bone(height: 36, radius: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Category header
            const _Bone(width: 140, height: 18),
            const SizedBox(height: 12),
            // Parameter cards
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: const _Bone(height: 80, radius: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trends Screen Skeleton ──────────────────────────────────────────────────

class TrendsScreenSkeleton extends StatelessWidget {
  const TrendsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _Bone(width: 140, height: 16),
                        _Bone(width: 60, height: 12),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _Bone(height: 160, radius: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
