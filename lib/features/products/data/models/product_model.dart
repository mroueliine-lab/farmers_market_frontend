class Product {
  final int id;
  final String name;
  final String description;
  final double priceFcfa;
  final int categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceFcfa,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      priceFcfa: double.tryParse(json['price_fcfa'].toString()) ?? 0.0,
      categoryId: json['category_id'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final int? parentId;
  final List<Category> children;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.children,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final childrenList = (json['children'] as List? ?? [])
        .map((c) => Category.fromJson(c))
        .toList();
    final productsList = (json['products'] as List? ?? [])
        .map((p) => Product.fromJson(p))
        .toList();
    return Category(
      id: json['id'],
      name: json['name'],
      parentId: json['parent_id'],
      children: childrenList,
      products: productsList,
    );
  }
}
