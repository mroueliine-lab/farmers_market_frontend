import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../products/data/models/product_model.dart';
import 'quantity_dialog.dart';

class ProductBrowser extends ConsumerWidget {
  final List<Category> categories;
  const ProductBrowser({super.key, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      trailing: Text(
                        '${product.priceFcfa.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => showQuantityDialog(context, ref, product),
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