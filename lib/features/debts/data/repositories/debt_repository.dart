import 'package:dio/dio.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final Dio _dio;
  DebtRepository(this._dio);

  Future<List<DebtModel>> getFarmerDebts(int farmerId) async {
    final response = await _dio.get('/farmers/$farmerId/debts');
    final list = response.data['data'] as List;
    return list.map((d) => DebtModel.fromJson(d)).toList();
  }

  Future<Map<String, dynamic>> recordRepayment({
    required int farmerId,
    required double kgReceived,
  }) async {
    final response = await _dio.post('/repayments', data: {
      'farmer_id': farmerId,
      'kg_received': kgReceived,
    });
    return response.data['data'];
  }
}
