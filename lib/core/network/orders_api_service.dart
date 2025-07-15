import '../constants/api_constants.dart';
import '../../shared/models/order_models.dart';
import 'api_client.dart';

class OrdersApiService {
  final ApiClient _apiClient;

  OrdersApiService(this._apiClient);

  /// Places a new order using the cosmic trader backend
  Future<PlaceOrderResponse> placeOrder(PlaceOrderRequest request) async {
    try {
      const String baseUrl = 'https://cosmic-trader-backend.onrender.com';

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$baseUrl/place_order',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received from place order',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      return PlaceOrderResponse.fromJson(response.data!);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to place order: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }
}
