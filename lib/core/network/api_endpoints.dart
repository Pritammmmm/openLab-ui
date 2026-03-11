class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String authGoogle = '/auth/google';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

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
}
