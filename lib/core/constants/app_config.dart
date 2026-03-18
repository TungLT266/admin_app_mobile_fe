class AppConfig {
  AppConfig._();

  // Change this to your actual API base URL
  static const String baseUrl = 'https://admin-app-nestjs.vercel.app/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
