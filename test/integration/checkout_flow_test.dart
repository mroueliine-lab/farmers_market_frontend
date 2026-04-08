/// End-to-end widget test for the checkout flow.
///
/// Uses a real GoRouter (minimal routes) so context.go() succeeds,
/// and a FakeDio that responds without delay.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmers_market/features/cart/presentation/cart_screen.dart';
import 'package:farmers_market/features/cart/providers/cart_provider.dart';
import 'package:farmers_market/features/products/providers/product_provider.dart';
import 'package:farmers_market/core/providers.dart';
import '../helpers/fake_dio.dart';
import '../helpers/test_data.dart';

void setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
}

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(
          path: '/cart',
          builder: (_, __) => const CartScreen(),
        ),
        GoRoute(
          path: '/farmers/:id',
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('Farmer Profile'))),
        ),
      ],
    );

Future<ProviderContainer> pumpCart(
    WidgetTester tester, FakeDio dio) async {
  late ProviderContainer container;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(dio),
        categoriesProvider.overrideWith((ref) async => []),
      ],
      child: Builder(builder: (context) {
        container = ProviderScope.containerOf(context);
        return MaterialApp.router(routerConfig: _buildRouter());
      }),
    ),
  );

  // Wait for the router to settle on /cart and render CartScreen.
  await tester.pumpAndSettle();
  return container;
}

void main() {
  late FakeDio dio;

  setUp(() {
    dio = FakeDio();
    dio.onPost('/transactions',
        {'status': 'success', 'message': 'Order placed'});
  });

  testWidgets('full checkout: farmer + item → success snackbar + cart cleared',
      (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    final container = await pumpCart(tester, dio);

    // Arrange: set farmer and add product.
    container.read(cartProvider.notifier).setFarmer(testFarmer(id: 5));
    container.read(cartProvider.notifier)
        .addItem(testProduct(price: 500), quantity: 2);
    await tester.pump();

    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.textContaining('500 FCFA x 2'), findsOneWidget);

    // Act: tap checkout.
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // Assert: success snackbar visible and cart cleared.
    expect(find.text('Order placed successfully!'), findsOneWidget);
    expect(container.read(cartProvider).items, isEmpty);
    expect(container.read(cartProvider).farmer, isNull);
  });

  testWidgets('checkout with empty cart shows error dialog', (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    final container = await pumpCart(tester, dio);

    container.read(cartProvider.notifier).setFarmer(testFarmer());
    await tester.pump();

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // CartScreen shows error dialog then resets state.
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('API failure shows error dialog and preserves cart items',
      (tester) async {
    dio.onPostThrow('/transactions', Exception('Server unavailable'));

    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    final container = await pumpCart(tester, dio);

    container.read(cartProvider.notifier).setFarmer(testFarmer());
    container.read(cartProvider.notifier).addItem(testProduct());
    await tester.pump();

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // Error dialog shown, cart preserved.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(container.read(cartProvider).items, isNotEmpty);
  });
}
