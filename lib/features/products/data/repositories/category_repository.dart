import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../../../../core/network/api_response.dart';

class CategoryRepository {
  final Dio _dio;
  CategoryRepository(this._dio);

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    return ApiResponse.list(response).map((c) => Category.fromJson(c)).toList();
  }
}
