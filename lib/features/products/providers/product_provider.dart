import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';
import '../data/repositories/category_repository.dart';
import '../../../core/providers.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.read(dioProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.read(categoryRepositoryProvider).getCategories();
});
