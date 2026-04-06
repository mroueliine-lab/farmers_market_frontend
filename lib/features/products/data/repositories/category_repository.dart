import 'package:dio/dio.dart';
import '../models/product_model.dart';

class CategoryRepository {
  final Dio _dio;
  CategoryRepository(this._dio);

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    final list = response.data['data'] as List;
    return list.map((c) => Category.fromJson(c)).toList();
  }
}
