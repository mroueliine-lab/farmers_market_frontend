import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/order_repository.dart';
import '../providers/cart_provider.dart';
import '../../farmers/providers/farmer_provider.dart';
import '../../../core/providers.dart';

enum CheckoutStatus { idle, loading, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final String? errorMessage;
  final int? completedFarmerId;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.errorMessage,
    this.completedFarmerId,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? errorMessage,
    int? completedFarmerId,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      completedFarmerId: completedFarmerId ?? this.completedFarmerId,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(const CheckoutState());

  Future<void> checkout(String paymentMethod) async {
    final cart = _ref.read(cartProvider);

    if (cart.farmer == null) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'No farmer selected',
      );
      return;
    }

    if (cart.items.isEmpty) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'Cart is empty',
      );
      return;
    }

    state = state.copyWith(status: CheckoutStatus.loading);

    try {
      final repo = OrderRepository(_ref.read(dioProvider));
      await repo.placeOrder(
        farmerId: cart.farmer!.id,
        paymentMethod: paymentMethod,
        items: cart.items
            .map((i) => {'product_id': i.product.id, 'quantity': i.quantity})
            .toList(),
      );

      final farmerId = cart.farmer!.id;
      _ref.read(cartProvider.notifier).clear();
      _ref.invalidate(farmerDetailProvider(farmerId));

      state = state.copyWith(
        status: CheckoutStatus.success,
        completedFarmerId: farmerId,
      );
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});