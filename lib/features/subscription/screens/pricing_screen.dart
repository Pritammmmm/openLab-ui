import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/app_theme.dart';
import '../models/subscription_plan.dart';
import '../providers/subscription_provider.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _isAnnual = false;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final activePlan = ref.watch(activePlanProvider);
    final offeringsAsync = ref.watch(offeringsProvider);
    final packages =
        offeringsAsync.valueOrNull?.current?.availablePackages ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Choose Your Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            Text(
              'Unlock the full power\nof WiseBlood',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the plan that works best for you',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Billing toggle
            _BillingToggle(
              isAnnual: _isAnnual,
              onChanged: (v) => setState(() => _isAnnual = v),
            ),
            const SizedBox(height: 24),

            // Plan cards
            ...SubscriptionPlan.plans.map((plan) {
              final pkg = findPackage(packages, plan.tier, _isAnnual);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PlanCard(
                  plan: plan,
                  isAnnual: _isAnnual,
                  isCurrent: plan.tier == activePlan,
                  storePrice: pkg?.storeProduct.priceString,
                  isPurchasing: _isPurchasing,
                  onSelect: plan.monthlyPrice > 0 && !_isPurchasing
                      ? () => _purchase(pkg, plan)
                      : null,
                ),
              );
            }),

            const SizedBox(height: 8),
            Text(
              'Prices in INR · Cancel anytime · No hidden fees',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Fair usage: 50 reports/month · 5 uploads/day',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Restore purchases (required by Google Play)
            TextButton(
              onPressed: _isPurchasing ? null : _restore,
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(Package? pkg, SubscriptionPlan plan) async {
    if (pkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This plan is not available yet. Please try later.'),
        ),
      );
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final success = await purchasePackage(pkg);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to ${plan.name}!'),
            backgroundColor: AppColors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Purchase failed. Please try again.'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      await restorePurchases();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not restore purchases. Please try again.'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Billing Toggle — Monthly / Annual with save badge
// ─────────────────────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final bool isAnnual;
  final ValueChanged<bool> onChanged;

  const _BillingToggle({required this.isAnnual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: 'Monthly',
            isSelected: !isAnnual,
            onTap: () => onChanged(false),
          ),
          _ToggleTab(
            label: 'Annual',
            badge: 'Save 30%',
            isSelected: isAnnual,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.greenBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Card — Shows plan info, price, features, and CTA
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isAnnual;
  final bool isCurrent;
  final String? storePrice;
  final bool isPurchasing;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.plan,
    required this.isAnnual,
    required this.isCurrent,
    this.storePrice,
    this.isPurchasing = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isPopular = plan.isPopular;
    final effectiveMonthly = isAnnual && plan.annualPrice > 0
        ? (plan.annualPrice / 12).round()
        : plan.monthlyPrice;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular
              ? AppColors.primary
              : isCurrent
                  ? AppColors.green
                  : AppColors.surfaceBorder,
          width: isPopular || isCurrent ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: AppColors.primary,
              child: const Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name + badge
                Row(
                  children: [
                    Text(plan.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 8),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      plan.tagline,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price — show store price if available, else hardcoded
                if (plan.monthlyPrice == 0)
                  Text(
                    'Free',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  )
                else if (storePrice != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        storePrice!,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          isAnnual ? '/year' : '/month',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\u20B9',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                      ),
                      Text(
                        '$effectiveMonthly',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '/month',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),

                // Annual billing info (only for hardcoded fallback)
                if (isAnnual &&
                    plan.annualPrice > 0 &&
                    storePrice == null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\u20B9${plan.annualPrice}/year',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Save \u20B9${plan.annualSavings}',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Features
                ...plan.features.map((f) => _FeatureRow(feature: f)),

                // CTA
                if (!isCurrent && plan.monthlyPrice > 0) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPopular ? AppColors.primary : AppColors.surface,
                        foregroundColor:
                            isPopular ? Colors.white : AppColors.primary,
                        side: isPopular
                            ? null
                            : const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Get ${plan.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature Row — check or cross with label
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final PlanFeature feature;

  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            feature.included
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 18,
            color: feature.included
                ? AppColors.green
                : AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.label,
              style: TextStyle(
                fontSize: 13,
                color: feature.included
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
