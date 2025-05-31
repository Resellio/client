class NewCartTicket {
  NewCartTicket({
    required this.ticketTypeId,
    required this.eventName,
    required this.ticketType,
    required this.organizerName,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
  });

  factory NewCartTicket.fromJson(Map<String, dynamic> json) {
    return NewCartTicket(
      ticketTypeId: json['ticketTypeId'] as String? ?? '',
      eventName: json['eventName'] as String? ?? '',
      ticketType: json['ticketType'] as String? ?? '',
      organizerName: json['organizerName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: json['unitPrice'] as double? ?? 0.0,
      currency: json['currency'] as String? ?? '',
    );
  }

  final String ticketTypeId;
  final String eventName;
  final String ticketType;
  final String organizerName;
  int quantity;
  final double unitPrice;
  final String currency;

  double get totalPrice => unitPrice * quantity;
}
