import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market/features/cart/presentation/cart_screen.dart';
import 'package:farmers_market/features/cart/providers/cart_provider.dart';
import 'package:farmers_market/features/products/providers/product_provider.dart';
import 'package:farmers_market/core/providers.dart';
import '../helpers/fake_dio.dart';
import '../helpers/test_data.dart';

Widget buildCart({List<Override> extra = const []}) {
  return ProviderScope(
    overrides: [
      dioProvider.overrideWithValue(FakeDio()),
      categoriesProvider.overrideWith((ref) async => [testCategory()]),
      ...extra,
    ],
    child: const MaterialApp(home: CartScreen()),
  );
}

// Use an empty category list so only cart items appear in the product panel.
Widget buildCartNoCategories({List<Override> extra = const []}) {
  return ProviderScope(
    overrides: [
      dioProvider.overrideWithValue(FakeDio()),
      categoriesProvider.overrideWith((ref) async => []),
      ...extra,
    ],
    child: const MaterialApp(home: CartScreen()),
  );
}

void setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  testWidgets('shows "no farmer selected" warning when cart has no farmer',
      (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildCartNoCategories());
    await tester.pump();

    expect(find.text('No farmer selected — go to Farmers tab first'),
        findsOneWidget);
  });

  testWidgets('shows farmer name and available credit in banner',
      (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildCartNoCategories());
    await tester.pump();

    final ref = ProviderScope.containerOf(
        tester.element(find.byType(CartScreen)));
    ref.read(cartProvider.notifier).setFarmer(testFarmer(creditLimit: 5000));
    await tester.pump();

    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.textContaining('5000'), findsOneWidget);
  });

  testWidgets('shows "No items in cart" when cart is empty', (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildCartNoCategories());
    await tester.pump();

    expect(find.text('No items in cart'), findsOneWidget);
  });

  testWidgets('shows cart item subtitle with price and quantity',
      (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    // Empty categories so product browser doesn't also show "Tomato".
    await tester.pumpWidget(buildCartNoCategories());
    await tester.pump();

    final ref = ProviderScope.containerOf(
        tester.element(find.byType(CartScreen)));
    ref.read(cartProvider.notifier).setFarmer(testFarmer());
    ref.read(cartProvider.notifier).addItem(testProduct(price: 500), quantity: 3);
    await tester.pump();

    // The CartPanel ListTile subtitle is "500 FCFA x 3" — unique to the cart.
    expect(find.textContaining('500 FCFA x 3'), findsOneWidget);
    // "1500 FCFA" appears in both item trailing AND checkout total — check ≥ 1.
    expect(find.textContaining('1500 FCFA'), findsWidgets);
  });

  testWidgets('remove button deletes item from cart', (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildCartNoCategories());
    await tester.pump();

    final ref = ProviderScope.containerOf(
        tester.element(find.byType(CartScreen)));
    ref.read(cartProvider.notifier).setFarmer(testFarmer());
    ref.read(cartProvider.notifier).addItem(testProduct());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.remove_circle));
    await tester.pump();

    expect(find.text('No items in cart'), findsOneWidget);
  });

  testWidgets('product browser renders category tab and product after load',
      (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildCart());
    await tester.pumpAndSettle();

    expect(find.text('Vegetables'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
  });

  testWidgets('checkout button is present in cart panel', (tester) async {
    setMobileViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildCartNoCategories());
    await tester.pump();

    expect(find.text('Checkout'), findsOneWidget);
  });
}
