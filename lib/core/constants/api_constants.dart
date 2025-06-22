class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.extended.exchange';

  // API Version
  static const String apiVersion = '/api/v1';

  // Endpoints
  static const String markets = '$apiVersion/info/markets';
  static const String userPositions = '$apiVersion/user/positions';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Api-Key': 'c3a787da54ff6dc257e1b50836e00957',
  };

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
