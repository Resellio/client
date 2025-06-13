import 'package:resellio/features/user/tickets/model/address.dart';

class TicketDetails {
  const TicketDetails({
    required this.nameOnTicket,
    required this.price,
    required this.currency,
    required this.eventName,
    required this.organizerName,
    required this.startDate,
    required this.endDate,
    required this.address,
    required this.eventId,
    required this.qrcode,
    required this.used,
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json) {
    return TicketDetails(
      nameOnTicket: json['nameOnTicket'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      eventName: json['eventName'] as String,
      organizerName: json['organizerName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      eventId: json['eventId'] as String,
      qrcode: json['qrcode'] as String,
      used: json['used'] as bool? ?? false,
    );
  }

  final String nameOnTicket;
  final double price;
  final String currency;
  final String eventName;
  final String organizerName;
  final DateTime startDate;
  final DateTime endDate;
  final Address address;
  final String eventId;
  final String qrcode;
  final bool used;

  Map<String, dynamic> toJson() {
    return {
      'nameOnTicket': nameOnTicket,
      'price': price,
      'currency': currency,
      'eventName': eventName,
      'organizerName': organizerName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'address': address.toJson(),
      'eventId': eventId,
      'qrcode': qrcode,
      'used': used,
    };
  }
}
