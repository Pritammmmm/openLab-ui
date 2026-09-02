import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/subscription_plan.dart';
import '../providers/subscription_provider.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnnual = true;
  bool _isPurchasing = false;
  AnimationController? _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl?.dispose();
    super.dispose();
  }

  Widget _stagger(double delay, Widget child) {
    final ctrl = _entryCtrl;
    if (ctrl == null) return child;
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: ctrl,
      curve: Interval(delay, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (_, ch) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - curve.value)),
          child: ch,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlan = ref.watch(activePlanProvider);
    final offeringsAsync = ref.watch(offeringsProvider);
    final packages =
        offeringsAsync.valueOrNull?.current?.availablePackages ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                child: Column(
                  children: [
                    _stagger(0.0, _buildHero()),
                    const SizedBox(height: 24),
                    _stagger(
                      0.05,
                      Builder(builder: (_) {
                        final plusMonthly =
                            findPackage(packages, PlanTier.plus, false);
                        final plusAnnual =
                            findPackage(packages, PlanTier.plus, true);
                        String? savingsBadge;
                        if (plusMonthly != null && plusAnnual != null) {
                          final fullYear =
                              plusMonthly.storeProduct.price * 12;
                          if (fullYear > 0) {
                            final pct = (((fullYear -
                                            plusAnnual.storeProduct.price) /
                                        fullYear) *
                                    100)
                                .round();
                            if (pct > 0) savingsBadge = 'Save $pct%';
                          }
                        }
                        return _BillingToggle(
                          isAnnual: _isAnnual,
                          savingsBadge: savingsBadge,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _isAnnual = v);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    for (int i = 0;
                        i < SubscriptionPlan.plans.length;
                        i++) ...[
                      Builder(builder: (_) {
                        final plan = SubscriptionPlan.plans[i];
                        final pkg =
                            findPackage(packages, plan.tier, _isAnnual);
                        final monthlyPkg =
                            findPackage(packages, plan.tier, false);
                        final isCurrent = plan.tier == activePlan;
                        final isDowngrade =
                            plan.tier.index < activePlan.index;
                        return _stagger(
                          0.1 + i * 0.08,
                          _PlanCard(
                            plan: plan,
                            isAnnual: _isAnnual,
                            isCurrent: isCurrent,
                            isDowngrade: isDowngrade,
                            package: pkg,
                            monthlyPackage: monthlyPkg,
                            isPurchasing: _isPurchasing,
                            onSelect: plan.isPaid &&
                                    !_isPurchasing &&
                                    !isCurrent &&
                                    !isDowngrade &&
                                    pkg != null
                                ? () => _purchase(pkg, plan)
                                : null,
                          ),
                        );
                      }),
                      if (i < SubscriptionPlan.plans.length - 1)
                        const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 28),
                    _stagger(0.4, const _TrustBadges()),
                    const SizedBox(height: 24),
                    _stagger(
                      0.45,
                      Column(
                        children: [
                          Text(
                            'Prices in INR  ·  Cancel anytime  ·  No hidden fees',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fair usage: 50 reports/month  ·  5 uploads/day',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _stagger(
                      0.5,
                      GestureDetector(
                        onTap: _isPurchasing ? null : _restore,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Restore Purchases',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF5226CC), Color(0xFF9B6CF7)],
          ).createShader(bounds),
          child: const Text(
            'Go Premium',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your health deserves more.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textMuted.withValues(alpha: 0.8),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Future<void> _purchase(Package? pkg, SubscriptionPlan plan) async {
    if (pkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('This plan is not available yet. Please try later.')),
      );
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final dioClient = ref.read(dioClientProvider);
      final success = await purchasePackage(pkg, dioClient: dioClient);
      if (!mounted) return;
      if (success) {
        ref.read(authNotifierProvider.notifier).checkAuthStatus();
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
      await syncSubscriptionWithBackend(ref.read(dioClientProvider));
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

// ─── Billing toggle ─────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final bool isAnnual;
  final String? savingsBadge;
  final ValueChanged<bool> onChanged;

  const _BillingToggle({
    required this.isAnnual,
    this.savingsBadge,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            badge: savingsBadge,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(13),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : AppColors.greenBg,
                    borderRadius: BorderRadius.circular(7),
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

// ─── Plan card ──────────────────────────────────────────────────────────

class _PlanCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final bool isAnnual;
  final bool isCurrent;
  final bool isDowngrade;
  final Package? package;
  final Package? monthlyPackage;
  final bool isPurchasing;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.plan,
    required this.isAnnual,
    required this.isCurrent,
    this.isDowngrade = false,
    this.package,
    this.monthlyPackage,
    this.isPurchasing = false,
    this.onSelect,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _featuresExpanded = false;

  bool get _featured => widget.plan.isPopular;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final isAnnual = widget.isAnnual;
    final isCurrent = widget.isCurrent;
    final isDowngrade = widget.isDowngrade;
    final package = widget.package;
    final monthlyPackage = widget.monthlyPackage;
    final isPurchasing = widget.isPurchasing;
    final onSelect = widget.onSelect;
    final onDark = _featured;
    final titleColor = onDark ? Colors.white : AppColors.textPrimary;
    final subColor =
        onDark ? Colors.white.withValues(alpha: 0.75) : AppColors.textMuted;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: onDark ? null : AppColors.surface,
        gradient: onDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5226CC), Color(0xFF7B52F5)],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: onDark
              ? Colors.transparent
              : isCurrent
                  ? AppColors.green
                  : AppColors.divider.withValues(alpha: 0.5),
          width: isCurrent && !onDark ? 2 : 1,
        ),
        boxShadow: [
          if (onDark) ...[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] else
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
          if (_featured)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : _planAccentColor(plan.tier)
                                .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _planIcon(plan.tier),
                        size: 22,
                        color: onDark
                            ? Colors.white
                            : _planAccentColor(plan.tier),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.tagline,
                            style: TextStyle(
                              fontSize: 13,
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: onDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : AppColors.greenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 12,
                              color:
                                  onDark ? Colors.white : AppColors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: onDark
                                    ? Colors.white
                                    : AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price — always from Google Play
                _PriceSection(
                  plan: plan,
                  isAnnual: isAnnual,
                  package: package,
                  monthlyPackage: monthlyPackage,
                  onDark: onDark,
                  titleColor: titleColor,
                  subColor: subColor,
                ),
                const SizedBox(height: 20),

                // Features
                _buildFeaturesList(plan, onDark),
                const SizedBox(height: 6),

                // CTA
                if (plan.isFree)
                  _StatusPill(
                    label: isCurrent ? 'Current Plan' : 'Free Forever',
                    color: isCurrent ? AppColors.green : AppColors.textMuted,
                    bgColor: isCurrent
                        ? AppColors.greenBg
                        : AppColors.background,
                  )
                else if (isDowngrade)
                  const _StatusPill(
                    label: 'Included in your plan',
                    color: AppColors.green,
                    bgColor: AppColors.greenBg,
                  )
                else if (isCurrent)
                  const _StatusPill(
                    label: 'Current Plan',
                    color: AppColors.green,
                    bgColor: AppColors.greenBg,
                  )
                else
                  _CtaButton(
                    label: 'Get ${plan.name}',
                    onDark: onDark,
                    isPurchasing: isPurchasing,
                    onTap: onSelect,
                  ),

                if (plan.isPaid && !isCurrent && !isDowngrade) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      isAnnual ? 'Billed annually' : 'Billed monthly',
                      style: TextStyle(
                        fontSize: 11,
                        color: subColor,
                        fontWeight: FontWeight.w500,
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

  static IconData _planIcon(PlanTier tier) => switch (tier) {
        PlanTier.free => Icons.explore_rounded,
        PlanTier.plus => Icons.bolt_rounded,
        PlanTier.family => Icons.people_rounded,
      };

  static Color _planAccentColor(PlanTier tier) => switch (tier) {
        PlanTier.free => AppColors.textMuted,
        PlanTier.plus => AppColors.primary,
        PlanTier.family => const Color(0xFFAF52DE),
      };

  Widget _buildFeaturesList(SubscriptionPlan plan, bool onDark) {
    final allFeatures = plan.features
        .where((f) => f.included || plan.isFree)
        .toList();
    final collapsible =
        plan.tier == PlanTier.plus && allFeatures.length > 2;
    final visible = collapsible && !_featuresExpanded
        ? allFeatures.take(2).toList()
        : allFeatures;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          for (final f in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeatureRow(feature: f, onDark: onDark),
            ),
          if (collapsible)
            GestureDetector(
              onTap: () =>
                  setState(() => _featuresExpanded = !_featuresExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _featuresExpanded
                          ? 'Show less'
                          : 'Show all features',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _featuresExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: onDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Price section (100% store-driven) ─────────────────────────────────

class _PriceSection extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isAnnual;
  final Package? package;
  final Package? monthlyPackage;
  final bool onDark;
  final Color titleColor;
  final Color subColor;

  const _PriceSection({
    required this.plan,
    required this.isAnnual,
    required this.package,
    required this.monthlyPackage,
    required this.onDark,
    required this.titleColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.isFree) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Free',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: titleColor,
              height: 1,
              letterSpacing: -1.2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 5),
            child: Text(
              'forever',
              style: TextStyle(fontSize: 14, color: subColor),
            ),
          ),
        ],
      );
    }

    final product = package?.storeProduct;
    if (product == null) {
      return _PriceSkeleton(onDark: onDark);
    }

    debugPrint('[PRICE] ${product.identifier}: '
        'price=${product.price}, priceString=${product.priceString}, '
        'pricePerMonth=${product.pricePerMonth}, '
        'pricePerMonthString=${product.pricePerMonthString}, '
        'pricePerYear=${product.pricePerYear}, '
        'pricePerYearString=${product.pricePerYearString}, '
        'currencyCode=${product.currencyCode}');

    final priceString = product.priceString;
    final priceAmount = product.price;

    if (isAnnual) {
      final monthlyPriceStr = product.pricePerMonthString ??
          NumberFormat.simpleCurrency(name: product.currencyCode)
              .format(priceAmount / 12);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  monthlyPriceStr,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Text(
                  '/month',
                  style: TextStyle(fontSize: 14, color: subColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$priceString / year',
            style: TextStyle(
              fontSize: 13,
              color: subColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _SavingsBadge(
            annualAmount: priceAmount,
            monthlyProduct: monthlyPackage?.storeProduct,
            onDark: onDark,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                priceString,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                '/month',
                style: TextStyle(fontSize: 14, color: subColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

}

// ─── Savings badge (computed from store prices) ───────────────────────

class _SavingsBadge extends StatelessWidget {
  final double annualAmount;
  final StoreProduct? monthlyProduct;
  final bool onDark;

  const _SavingsBadge({
    required this.annualAmount,
    required this.monthlyProduct,
    required this.onDark,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyProduct == null || monthlyProduct!.price <= 0) {
      return const SizedBox.shrink();
    }

    final fullYearCost = monthlyProduct!.price * 12;
    final savings =
        (((fullYearCost - annualAmount) / fullYearCost) * 100).round();
    if (savings <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.15)
            : AppColors.greenBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Save $savings%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: onDark ? Colors.white : AppColors.green,
        ),
      ),
    );
  }
}

// ─── Price skeleton (loading placeholder) ──────────────────────────────

class _PriceSkeleton extends StatelessWidget {
  final bool onDark;

  const _PriceSkeleton({required this.onDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = onDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.divider.withValues(alpha: 0.4);

    return Row(
      children: [
        Container(
          width: 100,
          height: 34,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 48,
          height: 16,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

// ─── Feature row ────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final PlanFeature feature;
  final bool onDark;

  const _FeatureRow({required this.feature, required this.onDark});

  @override
  Widget build(BuildContext context) {
    final included = feature.included;
    final iconBg = included
        ? (onDark
            ? Colors.white.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.08))
        : (onDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.textMuted.withValues(alpha: 0.06));
    final iconColor = included
        ? (onDark ? Colors.white : AppColors.primary)
        : (onDark
            ? Colors.white.withValues(alpha: 0.25)
            : AppColors.textMuted.withValues(alpha: 0.35));
    final textColor = included
        ? (onDark ? Colors.white : AppColors.textPrimary)
        : (onDark
            ? Colors.white.withValues(alpha: 0.4)
            : AppColors.textMuted.withValues(alpha: 0.6));

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            included ? Icons.check_rounded : Icons.close_rounded,
            size: 13,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            feature.label,
            style: TextStyle(
              fontSize: 13.5,
              color: textColor,
              fontWeight: included ? FontWeight.w500 : FontWeight.w400,
              decoration:
                  included ? null : TextDecoration.lineThrough,
              decorationColor: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── CTA button ─────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final String label;
  final bool onDark;
  final bool isPurchasing;
  final VoidCallback? onTap;

  const _CtaButton({
    required this.label,
    required this.onDark,
    required this.isPurchasing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: onDark ? Colors.white : AppColors.primary,
          foregroundColor: onDark ? AppColors.primary : Colors.white,
          disabledBackgroundColor: onDark
              ? Colors.white.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.4),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isPurchasing
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: onDark ? AppColors.primary : Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: onDark ? AppColors.primary : Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ─── Trust badges ───────────────────────────────────────────────────────

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.lock_rounded,
              label: 'Secure\nPayment',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.divider.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.replay_rounded,
              label: 'Cancel\nAnytime',
              color: const Color(0xFFFF9500),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.divider.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_user_rounded,
              label: 'Google Play\nVerified',
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
