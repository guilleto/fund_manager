class AppConstants {
  static const String appName = 'Fund Manager';
  static const String appVersion = '0.0.1';

  // API Constants
  static const String baseUrl = 'https://api.fundmanager.com';
  static const String apiVersion = '/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String themeKey = 'app_theme';
  static const String userPreferencesKey = 'user_preferences';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
