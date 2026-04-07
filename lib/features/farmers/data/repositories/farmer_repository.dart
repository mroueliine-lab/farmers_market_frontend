import 'package:dio/dio.dart';
import '../models/farmer_model.dart';

class FarmerRepository {
  final Dio _dio;

  FarmerRepository(this._dio);

  Future<Farmer?> search(String query) async {
    try {
      final response = await _dio.get('/farmers/search', queryParameters: {'q': query});
      return Farmer.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Farmer> show(int id) async {
    final response = await _dio.get('/farmers/$id');
    return Farmer.fromJson(response.data['data']);
  }

  Future<Farmer> create({
    required String firstname,
    required String lastname,
    required String email,
    required String phoneNumber,
    required String identifier,
    required double creditLimit,
  }) async {
    final response = await _dio.post('/farmers', data: {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone_number': phoneNumber,
      'identifier': identifier,
      'credit_limit': creditLimit,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    data['debts'] = [];
    return Farmer.fromJson(data);
  }
}
