import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item_model.dart';
import '../../products/data/models/product_model.dart';
import '../../farmers/data/models/farmer_model.dart';

class CartState {
  final List<CartItem> items;
  final Farmer? farmer;

  CartState({this.items = const [], this.farmer});

  double get total => items.fold(0, (sum, item) => sum + item.total);

  CartState copyWith({List<CartItem>? items, Farmer? farmer}) {
    return CartState(
      items: items ?? this.items,
      farmer: farmer ?? this.farmer,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void setFarmer(Farmer farmer) {
    state = CartState(items: [], farmer: farmer);
  }

  void addItem(Product product, {int quantity = 1}) {
    final index = state.items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + quantity);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(product: product, quantity: quantity)]);
    }
  }

  void removeProduct(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = state.items.map((i) {
      return i.product.id == productId ? i.copyWith(quantity: quantity) : i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void clear() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
