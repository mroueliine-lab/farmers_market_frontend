import 'package:dio/dio.dart';
import '../models/debt_model.dart';
import '../../../../core/network/api_response.dart';

class DebtRepository {
  final Dio _dio;
  DebtRepository(this._dio);

  Future<List<DebtModel>> getFarmerDebts(int farmerId) async {
    final response = await _dio.get('/farmers/$farmerId/debts');
    return ApiResponse.list(response).map((d) => DebtModel.fromJson(d)).toList();
  }

  Future<Map<String, dynamic>> recordRepayment({
    required int farmerId,
    required double kgReceived,
  }) async {
    final response = await _dio.post('/repayments', data: {
      'farmer_id': farmerId,
      'kg_received': kgReceived,
    });
    return ApiResponse.object(response);
  }
}
