import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../products/data/models/product_model.dart';
import '../../providers/cart_provider.dart';

void showQuantityDialog(BuildContext context, WidgetRef ref, Product product) {
  final qtyController = TextEditingController(text: '1');
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(product.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${product.priceFcfa.toStringAsFixed(0)} FCFA per unit'),
          const SizedBox(height: 12),
          TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(qtyController.text);
            if (qty != null && qty > 0) {
              final cart = ref.read(cartProvider);
              final exists = cart.items.any((i) => i.product.id == product.id);
              if (!exists) {
                ref.read(cartProvider.notifier).addProduct(product);
              }
              ref.read(cartProvider.notifier).updateQuantity(product.id, qty);
            }
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
