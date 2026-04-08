import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';

class OrderRepository {
  final Dio _dio;
  OrderRepository(this._dio);

  Future<Map<String, dynamic>> placeOrder({
    required int farmerId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _dio.post('/transactions', data: {
      'farmer_id': farmerId,
      'payment_method': paymentMethod,
      'items': items,
    });
    return ApiResponse.raw(response);
  }
}
