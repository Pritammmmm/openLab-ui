enum PlanTier { free, plus, family }

class PlanFeature {
  final String label;
  final bool included;

  const PlanFeature(this.label, {this.included = true});
}

class SubscriptionPlan {
  final PlanTier tier;
  final String name;
  final String tagline;
  final int monthlyPrice; // INR
  final int annualPrice; // INR total for 12 months
  final bool isPopular;
  final List<PlanFeature> features;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.annualPrice,
    this.isPopular = false,
    required this.features,
  });

  int get annualSavings => (monthlyPrice * 12) - annualPrice;
  int get savingsPercent =>
      monthlyPrice > 0 ? ((annualSavings / (monthlyPrice * 12)) * 100).round() : 0;

  static const List<SubscriptionPlan> plans = [free, plus, family];

  static const free = SubscriptionPlan(
    tier: PlanTier.free,
    name: 'Free',
    tagline: 'Get started',
    monthlyPrice: 0,
    annualPrice: 0,
    features: [
      PlanFeature('3 report uploads'),
      PlanFeature('Health score analysis'),
      PlanFeature('Basic insights'),
      PlanFeature('Parameter trends', included: false),
      PlanFeature('Full report history', included: false),
      PlanFeature('Health activity heatmap', included: false),
      PlanFeature('Family profiles', included: false),
    ],
  );

  static const plus = SubscriptionPlan(
    tier: PlanTier.plus,
    name: 'Plus',
    tagline: 'For individuals',
    monthlyPrice: 299,
    annualPrice: 2499,
    isPopular: true,
    features: [
      PlanFeature('Unlimited reports'),
      PlanFeature('Health score analysis'),
      PlanFeature('Full smart insights'),
      PlanFeature('Parameter trends'),
      PlanFeature('Full report history'),
      PlanFeature('Health activity heatmap'),
      PlanFeature('1 family member'),
      PlanFeature('Export & share reports'),
    ],
  );

  static const family = SubscriptionPlan(
    tier: PlanTier.family,
    name: 'Family',
    tagline: 'For the whole family',
    monthlyPrice: 599,
    annualPrice: 4999,
    isPopular: false,
    features: [
      PlanFeature('Unlimited reports'),
      PlanFeature('Health score analysis'),
      PlanFeature('Full smart insights'),
      PlanFeature('Parameter trends'),
      PlanFeature('Full report history'),
      PlanFeature('Health activity heatmap'),
      PlanFeature('Up to 5 family members'),
      PlanFeature('Export & share reports'),
      PlanFeature('Priority support'),
    ],
  );
}
