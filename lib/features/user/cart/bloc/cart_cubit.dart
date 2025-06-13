import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/user/cart/bloc/cart_state.dart';
import 'package:resellio/features/user/cart/model/cart_item.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required this.apiService}) : super(CartInitialState());

  final ApiService apiService;

  Future<void> fetchCart() async {
    if (state is CartLoadingState) {
      return;
    }

    emit(CartLoadingState());
    try {
      final cartResponse = await apiService.getCart();
      final cartData = cartResponse.data;
      final newTickets = (cartData?['newTickets'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
      final resellTickets = (cartData?['resellTickets'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
      final items = [...newTickets, ...resellTickets];
      final totalPrice = _calculateTotalPrice(items);
      emit(CartLoadedState(items: items, totalPrice: totalPrice));
    } catch (err) {
      emit(CartErrorState(message: 'Failed to load cart: $err'));
    }
  }

  Future<void> addTicketToCart(String ticketTypeId, int quantity) async {
    try {
      await apiService.addTicket(
        ticketTypeId: ticketTypeId,
        quantity: quantity,
      );
      await fetchCart();
    } catch (err) {
      emit(CartErrorState(message: 'Failed to add ticket: $err'));
    }
  }

  Future<void> removeTicket(String ticketTypeId, int quantity) async {
    try {
      await apiService.removeTicket(
        ticketTypeId: ticketTypeId,
        quantity: quantity,
      );
      await fetchCart();
    } catch (err) {
      emit(CartErrorState(message: 'Failed to remove ticket: $err'));
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    final currentState = state;
    if (currentState is! CartLoadedState) {
      return;
    }

    if (index < 0 || index >= currentState.items.length) {
      emit(CartErrorState(message: 'Invalid item index'));
      return;
    }

    final item = currentState.items[index];

    // Only new cart items can have their quantity updated
    if (item is! NewCartItem) {
      emit(CartErrorState(message: 'Cannot update quantity for resell items'));
      return;
    }

    if (newQuantity <= 0) {
      // If quantity is 0 or negative, remove the item
      await removeItem(index);
      return;
    }

    try {
      final ticketTypeId = item.ticket.ticketTypeId;
      final currentQuantity = item.ticket.quantity;
      final quantityDiff = newQuantity - currentQuantity;

      if (quantityDiff > 0) {
        // Add more tickets
        await apiService.addTicket(
          ticketTypeId: ticketTypeId,
          quantity: quantityDiff,
        );
      } else if (quantityDiff < 0) {
        // Remove some tickets
        await apiService.removeTicket(
          ticketTypeId: ticketTypeId,
          quantity: -quantityDiff,
        );
      }
      // If quantityDiff == 0, no change needed

      await fetchCart();
    } catch (err) {
      emit(CartErrorState(message: 'Failed to update quantity: $err'));
    }
  }

  Future<void> removeItem(int index) async {
    final currentState = state;
    if (currentState is! CartLoadedState) {
      return;
    }

    if (index < 0 || index >= currentState.items.length) {
      emit(CartErrorState(message: 'Invalid item index'));
      return;
    }

    final item = currentState.items[index];

    // Extract ticketTypeId and quantity based on cart item type
    String ticketTypeId;
    int quantity;

    if (item is ResellCartItem) {
      ticketTypeId = item.ticket.ticketId;
      quantity = 1;
    } else if (item is NewCartItem) {
      ticketTypeId = item.ticket.ticketTypeId;
      quantity = item.ticket.quantity;
    } else {
      emit(CartErrorState(message: 'Unknown cart item type'));
      return;
    }

    await removeTicket(ticketTypeId, quantity);
  }

  double _calculateTotalPrice(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
