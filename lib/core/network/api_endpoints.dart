class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String authGoogle = '/auth/google';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authOnboardingComplete = '/auth/onboarding-complete';

  // Users
  static const String users = '/users';

  // Profiles
  static const String profiles = '/profiles';
  static String profileById(String id) => '/profiles/$id';
  static String profileSetDefault(String id) => '/profiles/$id/set-default';

  // Reports
  static const String reports = '/reports';
  static const String reportUpload = '/reports/upload';
  static String reportById(String id) => '/reports/$id';
  static String reportStatus(String id) => '/reports/$id/status';
  static String reportsByProfile(String profileId) =>
      '/reports/profile/$profileId';
  static String reportCompare(String id) => '/reports/$id/compare';

  // Trends
  static String trends(String profileId) => '/reports/profile/$profileId/trends';

  // Subscription
  static const String subscriptionSync = '/subscription/sync';
  static const String subscriptionStatus = '/subscription/status';

  // Health
  static const String healthMetrics = '/health/metrics';
  static const String healthMetricsSync = '/health/metrics/sync';
  static String healthMetricById(String id) => '/health/metrics/$id';
  static const String healthDailyLogs = '/health/daily-logs';
  static const String healthDailyLogsSync = '/health/daily-logs/sync';
  static const String healthFoodEntries = '/health/food-entries';
  static const String healthFoodEntriesSync = '/health/food-entries/sync';
  static const String healthGoals = '/health/goals';
  static String healthGoalById(String id) => '/health/goals/$id';
  static const String healthInsights = '/health/insights';

  // Food Database
  static const String foodDbSearch = '/food-db/search';
  static const String foodDbCategories = '/food-db/categories';
}
