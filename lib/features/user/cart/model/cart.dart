import 'package:resellio/features/user/cart/model/cart_item.dart';
import 'package:resellio/features/user/cart/model/new_cart_ticket.dart';
import 'package:resellio/features/user/cart/model/resell_cart_ticket.dart';

class Cart {
  const Cart({required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final items = <CartItem>[];

    final newTickets = json['newTickets'] as List<dynamic>? ?? [];
    for (final ticket in newTickets) {
      items.add(
        NewCartItem(NewCartTicket.fromJson(ticket as Map<String, dynamic>)),
      );
    }

    final resellTickets = json['resellTickets'] as List<dynamic>? ?? [];
    for (final ticket in resellTickets) {
      items.add(ResellCartItem(
          ResellCartTicket.fromJson(ticket as Map<String, dynamic>)),);
    }

    return Cart(items: items);
  }

  final List<CartItem> items;
}
