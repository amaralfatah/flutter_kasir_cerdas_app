class AppConstants {
  // API related
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // App information
  static const String appName = 'Kasir Cerdas';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 15;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}