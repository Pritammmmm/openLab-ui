class AppConfig {
  AppConfig._();

  static const String appName = 'BloodWise';
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

  static const int maxProfilesFree = 1;
  static const int maxProfilesPremium = 10;

  static const double processingPollInterval = 2.5;

  static const String termsUrl = 'https://bloodwise.app/terms';
  static const String privacyUrl = 'https://bloodwise.app/privacy';
}
