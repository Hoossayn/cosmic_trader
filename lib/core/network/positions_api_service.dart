import '../constants/api_constants.dart';
import '../../shared/models/position_models.dart';
import 'api_client.dart';

class PositionsApiService {
  final ApiClient _apiClient;

  PositionsApiService(this._apiClient);

  /// Fetches user's active positions from Extended Exchange
  Future<List<Position>> getUserPositions() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.userPositions,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final positionsResponse = PositionsResponse.fromJson(response.data!);

      if (positionsResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${positionsResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      // Filter only opened positions
      final openPositions = positionsResponse.data
          .where((position) => position.isOpened)
          .toList();

      return openPositions;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse positions data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Fetches all positions (including closed ones)
  Future<List<Position>> getAllPositions() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.userPositions,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final positionsResponse = PositionsResponse.fromJson(response.data!);

      if (positionsResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${positionsResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      return positionsResponse.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse positions data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Fetches positions for a specific market
  Future<List<Position>> getPositionsByMarket(String market) async {
    try {
      final positions = await getAllPositions();
      return positions
          .where(
            (position) => position.market.toLowerCase() == market.toLowerCase(),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches positions filtered by side (LONG/SHORT)
  Future<List<Position>> getPositionsBySide(String side) async {
    try {
      final positions = await getAllPositions();
      return positions
          .where(
            (position) => position.side.toLowerCase() == side.toLowerCase(),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Calculates total unrealized PnL across all open positions
  Future<double> getTotalUnrealizedPnl() async {
    try {
      final openPositions = await getUserPositions();
      return openPositions.fold<double>(
        0.0,
        (sum, position) => sum + position.unrealisedPnlValue,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Calculates total margin used across all open positions
  Future<double> getTotalMarginUsed() async {
    try {
      final openPositions = await getUserPositions();
      return openPositions.fold<double>(
        0.0,
        (sum, position) => sum + position.marginValue,
      );
    } catch (e) {
      rethrow;
    }
  }
}
