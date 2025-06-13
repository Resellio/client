import 'package:resellio/features/user/cart/model/cart_item.dart';

sealed class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  CartLoadedState({required this.items, required this.totalPrice});

  final List<CartItem> items;
  final double totalPrice;
}

class CartErrorState extends CartState {
  CartErrorState({required this.message});

  final String message;
}
