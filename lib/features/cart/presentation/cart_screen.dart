import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../data/repositories/order_repository.dart';
import '../../products/providers/product_provider.dart';
import '../../products/data/models/product_model.dart';
import '../../../core/providers.dart';
import '../../farmers/providers/farmer_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  String _paymentMethod = 'cash';
  bool _loading = false;

  Future<void> _checkout() async {
    final cart = ref.read(cartProvider);
    if (cart.farmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farmer selected')),
      );
      return;
    }
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = OrderRepository(ref.read(dioProvider));
      await repo.placeOrder(
        farmerId: cart.farmer!.id,
        paymentMethod: _paymentMethod,
        items: cart.items
            .map((i) => {'product_id': i.product.id, 'quantity': i.quantity})
            .toList(),
      );
      final farmerId = cart.farmer!.id;
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(farmerDetailProvider(farmerId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go('/farmers/$farmerId');
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Farmer info banner
          if (cart.farmer != null)
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cart.farmer!.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Credit: ${cart.farmer!.availableCredit.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            )
          else
            Container(
              color: Colors.orange.shade50,
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('No farmer selected — go to Farmers tab first'),
                ],
              ),
            ),

          // Product browser
          Expanded(
            flex: 3,
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (categories) => _ProductBrowser(categories: categories),
            ),
          ),

          const Divider(height: 1),

          // Cart items
          if (cart.items.isNotEmpty)
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return ListTile(
                    dense: true,
                    title: Text(item.product.name),
                    subtitle: Text('${item.product.priceFcfa.toStringAsFixed(0)} FCFA x ${item.quantity}'),
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

          // Total + payment + checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                    Text('${cart.total.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Payment: '),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Cash'),
                      selected: _paymentMethod == 'cash',
                      onSelected: (_) => setState(() => _paymentMethod = 'cash'),
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: _paymentMethod == 'cash' ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Credit'),
                      selected: _paymentMethod == 'credit',
                      onSelected: (_) => setState(() => _paymentMethod = 'credit'),
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: _paymentMethod == 'credit' ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _checkout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Checkout', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductBrowser extends ConsumerWidget {
  final List<Category> categories;
  const _ProductBrowser({required this.categories});

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
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => ref.read(cartProvider.notifier).addProduct(product),
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
