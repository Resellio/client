import 'package:resellio/features/user/cart/model/cart_item.dart';

sealed class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  CartLoadedState({
    required this.items, 
    required this.totalPrice, 
    this.successMessage,
    this.errorMessage,
  });

  final List<CartItem> items;
  final double totalPrice;
  final String? successMessage;
  final String? errorMessage;
}

class CartErrorState extends CartState {
  CartErrorState({required this.message});

  final String message;
}

class CartSuccessState extends CartState {
  CartSuccessState({
    required this.items, 
    required this.totalPrice, 
    required this.message,
  });

  final List<CartItem> items;
  final double totalPrice;
  final String message;
}
