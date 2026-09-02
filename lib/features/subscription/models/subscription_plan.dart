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
  final bool isPopular;
  final List<PlanFeature> features;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.tagline,
    this.isPopular = false,
    required this.features,
  });

  bool get isFree => tier == PlanTier.free;
  bool get isPaid => tier != PlanTier.free;

  static const List<SubscriptionPlan> plans = [free, plus, family];

  static const free = SubscriptionPlan(
    tier: PlanTier.free,
    name: 'Free',
    tagline: 'Get started',
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
