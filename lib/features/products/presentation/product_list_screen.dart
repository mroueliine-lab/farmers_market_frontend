import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../data/models/product_model.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories found'));
        }
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
                    return _CategoryTab(category: category);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final Category category;
  const _CategoryTab({required this.category});

  @override
  Widget build(BuildContext context) {
    // If category has children, show each child with its products
    if (category.children.isNotEmpty) {
      return ListView(
        children: category.children.map((child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(child.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...child.products.map((p) => _ProductTile(product: p)),
            ],
          );
        }).toList(),
      );
    }

    // If no children, show products directly
    if (category.products.isEmpty) {
      return const Center(child: Text('No products in this category'));
    }
    return ListView(
      children: category.products.map((p) => _ProductTile(product: p)).toList(),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text(product.description),
      trailing: Text(
        '${product.priceFcfa.toStringAsFixed(0)} FCFA',
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.green),
      ),
      onTap: () {
        // Will add to cart — coming next
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} added to cart')),
        );
      },
    );
  }
}
