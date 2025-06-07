import 'package:equatable/equatable.dart';

class TicketType extends Equatable {
  const TicketType({
    required this.id,
    required this.description,
    required this.price,
    required this.currency,
    required this.availableFrom,
    required this.amountAvailable,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as double? ?? 0.0,
      currency: json['currency'] as String? ?? '',
      availableFrom: DateTime.parse(json['availableFrom'] as String? ?? ''),
      amountAvailable: json['amountAvailable'] as int? ?? 0,
    );
  }

  final String id;
  final String description;
  final double price;
  final String currency;
  final DateTime availableFrom;
  final int amountAvailable;

  @override
  List<Object?> get props =>
      [id, description, price, currency, availableFrom, amountAvailable];
}
