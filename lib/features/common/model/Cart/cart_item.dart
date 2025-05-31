import 'package:resellio/features/common/model/Cart/new_cart_ticket.dart';
import 'package:resellio/features/common/model/Cart/resell_cart_ticket.dart';

abstract class CartItem {
  String get eventName;
  String get ticketType;
  String get organizerName;
  double get totalPrice;
  String get currency;
  bool get isResell;
}

class ResellCartItem implements CartItem {
  const ResellCartItem(this.ticket);

  final ResellCartTicket ticket;

  @override
  String get eventName => ticket.eventName;

  @override
  String get ticketType => ticket.ticketType;

  @override
  String get organizerName => ticket.organizerName;

  @override
  double get totalPrice => ticket.price;

  @override
  String get currency => ticket.currency;

  @override
  bool get isResell => true;
}

class NewCartItem implements CartItem {
  const NewCartItem(this.ticket);

  final NewCartTicket ticket;

  @override
  String get eventName => ticket.eventName;

  @override
  String get ticketType => ticket.ticketType;

  @override
  String get organizerName => ticket.organizerName;

  @override
  double get totalPrice => ticket.totalPrice;

  @override
  String get currency => ticket.currency;

  @override
  bool get isResell => false;
}
