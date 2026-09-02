import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/subscription/models/subscription_plan.dart';
import '../../features/subscription/providers/subscription_provider.dart';
import '../config/app_theme.dart';

/// Avatar with a gradient purple ring for premium (Plus / Family) users.
/// Free-plan users get the normal avatar with no ring.
class PremiumAvatar extends ConsumerWidget {
  final double radius;
  final String? photoUrl;
  final String fallbackText;
  final double fallbackFontSize;

  const PremiumAvatar({
    super.key,
    required this.radius,
    this.photoUrl,
    required this.fallbackText,
    this.fallbackFontSize = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(activePlanProvider);
    final isPremium = plan != PlanTier.free;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              fallbackText,
              style: TextStyle(
                fontSize: fallbackFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
          : null,
    );

    if (!isPremium) return avatar;

    // Gradient ring for premium users
    const ringWidth = 2.5;
    return Container(
      padding: const EdgeInsets.all(ringWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFA78BFA),
            Color(0xFF5F33E1),
            Color(0xFFC084FC),
            Color(0xFF7C3AED),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: avatar,
      ),
    );
  }
}
