import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../../core/responsive.dart';
import '../../../core/error_handler.dart';
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

  @override
  void initState() {
    super.initState();
    // Listen to checkout state changes
    ref.listenManual(checkoutProvider, (previous, next) {
      if (next.status == CheckoutStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go('/farmers/${next.completedFarmerId}');
        ref.read(checkoutProvider.notifier).reset();
      } else if (next.status == CheckoutStatus.error) {
        ErrorHandler.show(context, next.errorMessage ?? 'Unknown error');
        ref.read(checkoutProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
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
      loading: checkout.status == CheckoutStatus.loading,
      onPaymentChanged: (v) => setState(() => _paymentMethod = v),
      onCheckout: () => ref.read(checkoutProvider.notifier).checkout(_paymentMethod),
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
