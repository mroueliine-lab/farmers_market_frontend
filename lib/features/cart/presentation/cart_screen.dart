import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../data/repositories/order_repository.dart';
import '../../products/providers/product_provider.dart';
import '../../../core/providers.dart';
import '../../../core/responsive.dart';
import '../../../core/error_handler.dart';
import '../../farmers/providers/farmer_provider.dart';
import 'widgets/cart_farmer_banner.dart';
import 'widgets/cart_panel.dart';
import 'widgets/product_browser.dart';

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
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isWide = !Responsive.isMobile(context);

    final productBrowser = categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(ErrorHandler.getMessage(e))),
      data: (categories) => ProductBrowser(categories: categories),
    );

    final cartPanel = CartPanel(
      cart: cart,
      paymentMethod: _paymentMethod,
      loading: _loading,
      onPaymentChanged: (v) => setState(() => _paymentMethod = v),
      onCheckout: _checkout,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          CartFarmerBanner(cart: cart),
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      Expanded(flex: 3, child: productBrowser),
                      const VerticalDivider(width: 1),
                      Expanded(flex: 2, child: cartPanel),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(flex: 3, child: productBrowser),
                      const Divider(height: 1),
                      Expanded(flex: 2, child: cartPanel),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
