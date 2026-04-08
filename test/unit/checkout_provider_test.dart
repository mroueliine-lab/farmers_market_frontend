import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market/features/cart/providers/cart_provider.dart';
import 'package:farmers_market/features/cart/providers/checkout_provider.dart';
import 'package:farmers_market/core/providers.dart';
import '../helpers/fake_dio.dart';
import '../helpers/test_data.dart';

ProviderContainer makeContainer(Dio dio) {
  return ProviderContainer(
    overrides: [dioProvider.overrideWithValue(dio)],
  );
}

void main() {
  late FakeDio dio;
  late ProviderContainer container;

  const orderResponse = {'status': 'success', 'message': 'Order placed'};

  setUp(() {
    dio = FakeDio();
    container = makeContainer(dio);
  });

  tearDown(() => container.dispose());

  CheckoutNotifier notifier() => container.read(checkoutProvider.notifier);
  CheckoutState checkoutState() => container.read(checkoutProvider);
  CartNotifier cart() => container.read(cartProvider.notifier);

  group('checkout', () {
    test('errors when no farmer is selected', () async {
      await notifier().checkout('cash');

      expect(checkoutState().status, CheckoutStatus.error);
      expect(checkoutState().errorMessage, contains('farmer'));
    });

    test('errors when cart is empty', () async {
      cart().setFarmer(testFarmer());

      await notifier().checkout('cash');

      expect(checkoutState().status, CheckoutStatus.error);
      expect(checkoutState().errorMessage, contains('empty'));
    });

    test('transitions to success on valid cart and successful API call',
        () async {
      dio.onPost('/transactions', orderResponse);
      cart().setFarmer(testFarmer(id: 42));
      cart().addItem(testProduct());

      await notifier().checkout('cash');

      expect(checkoutState().status, CheckoutStatus.success);
      expect(checkoutState().completedFarmerId, 42);
    });

    test('clears cart after successful checkout', () async {
      dio.onPost('/transactions', orderResponse);
      cart().setFarmer(testFarmer());
      cart().addItem(testProduct());

      await notifier().checkout('cash');

      expect(container.read(cartProvider).items, isEmpty);
      expect(container.read(cartProvider).farmer, isNull);
    });

    test('transitions to error when API call fails', () async {
      dio.onPostThrow('/transactions', Exception('Server error'));
      cart().setFarmer(testFarmer());
      cart().addItem(testProduct());

      await notifier().checkout('cash');

      expect(checkoutState().status, CheckoutStatus.error);
      expect(checkoutState().errorMessage, isNotNull);
    });

    test('reset returns state to idle', () async {
      dio.onPost('/transactions', orderResponse);
      cart().setFarmer(testFarmer());
      cart().addItem(testProduct());
      await notifier().checkout('cash');

      notifier().reset();

      expect(checkoutState().status, CheckoutStatus.idle);
      expect(checkoutState().completedFarmerId, isNull);
    });
  });
}
