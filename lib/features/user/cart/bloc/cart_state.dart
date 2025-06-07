import 'package:resellio/features/common/model/Cart/cart_item.dart';

abstract class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  CartLoadedState({required this.items, required this.totalPrice});

  final List<CartItem> items;
  final double totalPrice;
}

class CartErrorState extends CartState {}
