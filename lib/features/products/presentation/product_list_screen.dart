import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import 'widgets/product_browser_widget.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) => ProductBrowserWidget(
        categories: categories,
        onProductTap: (product) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} — ${product.priceFcfa.toStringAsFixed(0)} FCFA')),
          );
        },
      ),
    );
  }
}