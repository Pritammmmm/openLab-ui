class AppConfig {
  AppConfig._();

  static const String appName = 'WiseBlood';
  static const String appTagline = 'Understand Your Health, Simply';

  // For real device: use your computer's LAN IP
  // For emulator: use 10.0.2.2
  static const String _host = '192.168.1.2';
  static const int _port = 3000;

  static String get baseUrl => 'http://$_host:$_port/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Duration accessTokenExpiry = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 7);

  // Profile limits per plan
  static const int maxProfilesFree = 1; // self only
  static const int plusMaxProfiles = 2; // self + 1
  static const int familyMaxProfiles = 6; // self + 5

  // Security & fair usage (enforced server-side)
  static const int maxUploadsPerDay = 5;
  static const int fairUseMonthlyLimit = 50;
  static const int freeReportCap = 3; // lifetime for free tier

  // RevenueCat
  static const String revenueCatGoogleApiKey = 'YOUR_REVENUECAT_GOOGLE_API_KEY';

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
  static const String privacyUrl = 'https://bloodwise.app/privacy';
}
