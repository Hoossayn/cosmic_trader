import '../constants/api_constants.dart';
import '../../shared/models/position_models.dart';
import 'api_client.dart';

class PositionsApiService {
  final ApiClient _apiClient;
  static const String baseUrl = 'https://cosmic-trader-backend.onrender.com';

  PositionsApiService(this._apiClient);

  /// Fetches open positions from the new backend
  Future<List<Position>> getOpenPositions() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$baseUrl/open_positions',
    );
    final data = response.data?['data'] as List<dynamic>?;
    if (data == null) return [];
    return data
        .map((e) => Position.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches closed positions from the new backend
  Future<List<Position>> getClosedPositions() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$baseUrl/closed_positions',
    );
    final data = response.data?['data'] as List<dynamic>?;
    if (data == null) return [];
    return data
        .map((e) => Position.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
