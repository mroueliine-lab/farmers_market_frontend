import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';

class CartFarmerBanner extends StatelessWidget {
  final CartState cart;
  const CartFarmerBanner({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    if (cart.farmer != null) {
      return Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(cart.farmer!.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Text(
              'Credit: ${cart.farmer!.availableCredit.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      );
    }
    return Container(
      color: Colors.orange.shade50,
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Flexible(child: Text('No farmer selected — go to Farmers tab first')),
        ],
      ),
    );
  }
}
