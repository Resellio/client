import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/Cart/cart_item.dart';
import 'package:resellio/features/common/model/Cart/new_cart_ticket.dart';
import 'package:resellio/features/common/model/Cart/resell_cart_ticket.dart';
import 'package:resellio/features/user/cart/bloc/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitialState());

  Future<void> fetchCart() async {
    emit(CartLoadingState());
    await Future.delayed(const Duration(seconds: 1));
    final mockCartItems = <CartItem>[
      const ResellCartItem(
        ResellCartTicket(
          ticketId: '123e4567-e89b-12d3-a456-426614174000',
          eventName: 'Koncert',
          ticketType: 'VIP',
          organizerName: 'Live Nation',
          originalOwnerEmail: 'jan@example.com',
          price: 150,
          currency: 'PLN',
        ),
      ),
      const NewCartItem(
        NewCartTicket(
          ticketTypeId: '987fcdeb-51a2-43d7-8f9e-123456789abc',
          eventName: 'Festiwal Orange',
          ticketType: 'Standard',
          organizerName: 'Orange Polska',
          quantity: 2,
          unitPrice: 80,
          currency: 'PLN',
        ),
      ),
      const ResellCartItem(
        ResellCartTicket(
          ticketId: '456e7890-e12b-34d5-a678-901234567890',
          eventName: 'Kraków Live Festival',
          ticketType: 'Premium',
          organizerName: 'Kraków Events',
          originalOwnerEmail: 'anna@example.com',
          price: 200,
          currency: 'PLN',
        ),
      ),
    ];
    final double totalPrice =
        mockCartItems.fold(0, (sum, item) => sum + item.totalPrice);
    emit(CartLoadedState(items: mockCartItems, totalPrice: totalPrice));
  }
}
