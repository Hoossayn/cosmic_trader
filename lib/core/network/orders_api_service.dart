import '../constants/api_constants.dart';
import '../../shared/models/order_models.dart';
import 'api_client.dart';

class OrdersApiService {
  final ApiClient _apiClient;

  OrdersApiService(this._apiClient);

  /// Fetches user's order history from Extended Exchange
  Future<List<Order>> getOrderHistory({int limit = 20, int? cursor}) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/user/orders/history',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final orderHistoryResponse = OrderHistoryResponse.fromJson(
        response.data!,
      );

      if (orderHistoryResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${orderHistoryResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      return orderHistoryResponse.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse order history data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Fetches order history filtered by market
  Future<List<Order>> getOrderHistoryByMarket({
    required String market,
    int limit = 20,
    int? cursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{'market': market, 'limit': limit};

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/user/orders/history',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final orderHistoryResponse = OrderHistoryResponse.fromJson(
        response.data!,
      );

      if (orderHistoryResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${orderHistoryResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      return orderHistoryResponse.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse order history data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Fetches order history filtered by side (BUY/SELL)
  Future<List<Order>> getOrderHistoryBySide({
    required String side,
    int limit = 20,
    int? cursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{'side': side, 'limit': limit};

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/user/orders/history',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final orderHistoryResponse = OrderHistoryResponse.fromJson(
        response.data!,
      );

      if (orderHistoryResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${orderHistoryResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      return orderHistoryResponse.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse order history data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Fetches order history filtered by status (FILLED, CANCELLED, etc.)
  Future<List<Order>> getOrderHistoryByStatus({
    required String status,
    int limit = 20,
    int? cursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{'status': status, 'limit': limit};

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/user/orders/history',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final orderHistoryResponse = OrderHistoryResponse.fromJson(
        response.data!,
      );

      if (orderHistoryResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${orderHistoryResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      return orderHistoryResponse.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse order history data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }
}
