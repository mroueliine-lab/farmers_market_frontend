import 'package:flutter/material.dart';

class CheckoutSheet extends StatelessWidget {
  final double total;
  final String paymentMethod;
  final bool loading;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onCheckout;

  const CheckoutSheet({
    super.key,
    required this.total,
    required this.paymentMethod,
    required this.loading,
    required this.onPaymentChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Payment:'),
              ChoiceChip(
                label: const Text('Cash'),
                selected: paymentMethod == 'cash',
                onSelected: (_) => onPaymentChanged('cash'),
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: paymentMethod == 'cash' ? Colors.white : Colors.black,
                ),
              ),
              ChoiceChip(
                label: const Text('Credit'),
                selected: paymentMethod == 'credit',
                onSelected: (_) => onPaymentChanged('credit'),
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: paymentMethod == 'credit' ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Checkout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}