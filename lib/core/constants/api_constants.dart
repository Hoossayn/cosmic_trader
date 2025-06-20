class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.extended.exchange';

  // API Version
  static const String apiVersion = '/api/v1';

  // Endpoints
  static const String markets = '$apiVersion/info/markets';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
