class AppConfig {
  AppConfig._();

  // Change this to your actual API base URL
  static const String baseUrl = 'http://localhost:3000';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
