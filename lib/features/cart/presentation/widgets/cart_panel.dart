import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import 'checkout_sheet.dart';

class CartPanel extends ConsumerWidget {
  final CartState cart;
  final String paymentMethod;
  final bool loading;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onCheckout;

  const CartPanel({
    super.key,
    required this.cart,
    required this.paymentMethod,
    required this.loading,
    required this.onPaymentChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: cart.items.isEmpty
              ? const Center(child: Text('No items in cart'))
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.product.name),
                      subtitle: Text(
                          '${item.product.priceFcfa.toStringAsFixed(0)} FCFA x ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${item.total.toStringAsFixed(0)} FCFA'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .removeProduct(item.product.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        CheckoutSheet(
          total: cart.total,
          paymentMethod: paymentMethod,
          loading: loading,
          onPaymentChanged: onPaymentChanged,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}
