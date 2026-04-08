import 'package:flutter/material.dart';
import 'package:farmers_market/features/products/data/models/product_model.dart';

class ProductBrowserWidget extends StatelessWidget {
  final List<Category> categories;
  final void Function(Product product) onProductTap;

  const ProductBrowserWidget({
    super.key,
    required this.categories,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const Center(child: Text('No categories'));
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Colors.green,
            tabs: categories.map((c) => Tab(text: c.name)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: categories.map((category) {
                final products = category.children.isNotEmpty
                    ? category.children.expand((c) => c.products).toList()
                    : category.products;
                if (products.isEmpty) {
                  return const Center(child: Text('No products'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: product.description.isNotEmpty
                          ? Text(product.description,
                              style: const TextStyle(color: Colors.grey))
                          : null,
                      trailing: Text(
                        '${product.priceFcfa.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => onProductTap(product),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
