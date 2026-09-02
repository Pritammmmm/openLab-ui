class AppConfig {
  AppConfig._();

  static const String appName = 'WiseBlood';
  static const String appTagline = 'Understand Your Health, Simply';

  // ── API base URL ──────────────────────────────────────────────────────────
  // Development: use your LAN IP (real device) or 10.0.2.2 (emulator)
  // Production:  set _prodBaseUrl to your HTTPS domain
  static const bool _useProduction = true;

  static const String _devHost = '192.168.1.3';
  static const int _devPort = 3000;
  static const String _prodBaseUrl = 'https://wiseblood-backend-production.up.railway.app/api';

  static String get baseUrl =>
      _useProduction ? _prodBaseUrl : 'http://$_devHost:$_devPort/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Profile limits per plan
  static const int maxProfilesFree = 1; // self only
  static const int plusMaxProfiles = 2; // self + 1
  static const int familyMaxProfiles = 6; // self + 5

  // Security & fair usage (enforced server-side)
  static const int maxUploadsPerDay = 5;
  static const int fairUseMonthlyLimit = 50;
  static const int freeReportCap = 3; // lifetime for free tier

  // RevenueCat
  static const String revenueCatGoogleApiKey = 'goog_svkiisdNlllcwPKGgyQMTQAOugQ';

  // Entitlement IDs (must match RevenueCat dashboard)
  static const String plusEntitlementId = 'plus';
  static const String familyEntitlementId = 'family';

  // Package identifiers (must match RevenueCat dashboard)
  static const String plusMonthlyId = 'plus_monthly';
  static const String plusAnnualId = 'plus_annual';
  static const String familyMonthlyId = 'family_monthly';
  static const String familyAnnualId = 'family_annual';

  static const double processingPollInterval = 2.5;

  static const String termsUrl = 'https://bloodwise.app/terms';
  static const String privacyUrl = 'https://pritammmmm.github.io/wiseblood-privacy/';
}
