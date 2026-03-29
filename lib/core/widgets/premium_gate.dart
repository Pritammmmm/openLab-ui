import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/subscription/models/subscription_plan.dart';
import '../../features/subscription/providers/subscription_provider.dart';
import '../config/app_theme.dart';
import 'app_button.dart';

/// Reusable gating widget.
///
/// If the user's plan meets [requiredPlan], shows [child].
/// Otherwise shows [lockedChild] or a default upgrade prompt.
///
/// Set [blurChild] to true to render [child] behind a blur + overlay
/// instead of replacing it entirely.
class PremiumGate extends ConsumerWidget {
  final PlanTier requiredPlan;
  final Widget child;
  final Widget? lockedChild;
  final bool blurChild;
  final String? featureName;

  const PremiumGate({
    super.key,
    this.requiredPlan = PlanTier.plus,
    required this.child,
    this.lockedChild,
    this.blurChild = false,
    this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activePlanProvider);
    final isUnlocked = activePlan.index >= requiredPlan.index;

    if (isUnlocked) return child;

    if (lockedChild != null) return lockedChild!;

    if (blurChild) {
      return ClipRect(
        child: Stack(
          children: [
            child,
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            Positioned.fill(
              child: _DefaultLockedOverlay(
                featureName: featureName,
                planName: requiredPlan.name,
              ),
            ),
          ],
        ),
      );
    }

    return _DefaultLockedCard(
      featureName: featureName,
      planName: requiredPlan.name,
    );
  }
}

/// Compact inline upgrade prompt card.
class _DefaultLockedCard extends StatelessWidget {
  final String? featureName;
  final String planName;

  const _DefaultLockedCard({this.featureName, required this.planName});

  @override
  Widget build(BuildContext context) {
    final label = featureName ?? 'This feature';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            '$label requires ${planName[0].toUpperCase()}${planName.substring(1)}',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Upgrade your plan to unlock this feature',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'View Plans',
              icon: Icons.star_rounded,
              onPressed: () => GoRouter.of(context).push('/pricing'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered overlay for blurred content.
class _DefaultLockedOverlay extends StatelessWidget {
  final String? featureName;
  final String planName;

  const _DefaultLockedOverlay({this.featureName, required this.planName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            featureName ?? 'Premium Feature',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => GoRouter.of(context).push('/pricing'),
            child: Text(
              'Upgrade to unlock',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small inline "Upgrade to see more" teaser row.
class UpgradeTeaser extends StatelessWidget {
  final String message;

  const UpgradeTeaser({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/pricing'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded,
                size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.primary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
