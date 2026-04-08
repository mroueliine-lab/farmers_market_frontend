import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market/features/cart/providers/cart_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  CartNotifier notifier() => container.read(cartProvider.notifier);
  CartState cartState() => container.read(cartProvider);

  group('addItem', () {
    test('adds a new product with the given quantity', () {
      notifier().addItem(testProduct(id: 1), quantity: 3);

      expect(cartState().items.length, 1);
      expect(cartState().items.first.product.id, 1);
      expect(cartState().items.first.quantity, 3);
    });

    test('increments quantity when same product added again', () {
      final product = testProduct(id: 1);

      notifier().addItem(product, quantity: 2);
      notifier().addItem(product, quantity: 3);

      expect(cartState().items.length, 1);
      expect(cartState().items.first.quantity, 5);
    });

    test('adds distinct products as separate entries', () {
      notifier().addItem(testProduct(id: 1), quantity: 1);
      notifier().addItem(testProduct(id: 2), quantity: 2);

      expect(cartState().items.length, 2);
    });

    test('defaults to quantity 1 when not specified', () {
      notifier().addItem(testProduct());

      expect(cartState().items.first.quantity, 1);
    });
  });

  group('removeProduct', () {
    test('removes the matching item', () {
      notifier().addItem(testProduct(id: 1));
      notifier().addItem(testProduct(id: 2));

      notifier().removeProduct(1);

      expect(cartState().items.length, 1);
      expect(cartState().items.first.product.id, 2);
    });

    test('is a no-op when product not in cart', () {
      notifier().addItem(testProduct(id: 1));

      notifier().removeProduct(99);

      expect(cartState().items.length, 1);
    });
  });

  group('updateQuantity', () {
    test('sets quantity to the given value', () {
      notifier().addItem(testProduct(id: 1), quantity: 2);

      notifier().updateQuantity(1, 7);

      expect(cartState().items.first.quantity, 7);
    });

    test('removes item when quantity is set to zero', () {
      notifier().addItem(testProduct(id: 1));

      notifier().updateQuantity(1, 0);

      expect(cartState().items, isEmpty);
    });

    test('removes item when quantity is negative', () {
      notifier().addItem(testProduct(id: 1));

      notifier().updateQuantity(1, -1);

      expect(cartState().items, isEmpty);
    });
  });

  group('total', () {
    test('sums price × quantity across all items', () {
      notifier().addItem(testProduct(id: 1, price: 500), quantity: 2);
      notifier().addItem(testProduct(id: 2, price: 300), quantity: 3);

      expect(cartState().total, 500 * 2 + 300 * 3);
    });

    test('is zero for an empty cart', () {
      expect(cartState().total, 0.0);
    });
  });

  group('setFarmer', () {
    test('sets the farmer and clears previous items', () {
      notifier().addItem(testProduct());
      final farmer = testFarmer();

      notifier().setFarmer(farmer);

      expect(cartState().farmer?.id, farmer.id);
      expect(cartState().items, isEmpty);
    });
  });

  group('clear', () {
    test('removes all items and farmer', () {
      notifier().setFarmer(testFarmer());
      notifier().addItem(testProduct());

      notifier().clear();

      expect(cartState().items, isEmpty);
      expect(cartState().farmer, isNull);
    });
  });
}
