import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmers_market/features/products/data/models/product_model.dart';
import 'package:farmers_market/features/products/presentation/widgets/product_browser_widget.dart';
import 'quantity_dialog.dart';

class ProductBrowser extends ConsumerWidget {
  final List<Category> categories;
  const ProductBrowser({super.key, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProductBrowserWidget(
      categories: categories,
      onProductTap: (product) => showQuantityDialog(context, ref, product),
    );
  }
}