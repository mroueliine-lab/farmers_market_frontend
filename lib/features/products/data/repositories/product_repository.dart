import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<List<Product>> getProducts() async {
    final response = await _dio.get('/products');
    final list = response.data['data'] as List;
    return list.map((p) => Product.fromJson(p)).toList();
  }

  Future<Product> show(int id) async {
        final response = await _dio.get('/products/$id');
        return Product.fromJson(response.data['data']);
    }

    Future<Product> create({
        required String name,
        required String description,
        required double priceFcfa,
        required int categoryId,
    }) async {
        final response = await _dio.post('/products', data: {
            'name': name,
            'description': description,
            'price_fcfa': priceFcfa,
            'category_id': categoryId,
        });
        return Product.fromJson(response.data);
    }

 Future<Product> update({
        required int id,
        String? name,
        String? description,
        double? priceFcfa,
        int? categoryId,
    }) async {
        final response = await _dio.put('/products/$id', data: {
            if (name != null) 'name': name,
            if (description != null) 'description': description,
            if (priceFcfa != null) 'price_fcfa': priceFcfa,
            if (categoryId != null) 'category_id': categoryId,
        });
        return Product.fromJson(response.data);

}

    Future<void> delete(int id) async {
        await _dio.delete('/products/$id');
    }
}