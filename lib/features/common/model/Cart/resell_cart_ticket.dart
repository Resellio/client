class ResellCartTicket {
  const ResellCartTicket({
    required this.ticketId,
    required this.eventName,
    required this.ticketType,
    required this.organizerName,
    required this.originalOwnerEmail,
    required this.price,
    required this.currency,
  });

  factory ResellCartTicket.fromJson(Map<String, dynamic> json) {
    return ResellCartTicket(
      ticketId: json['ticketId'] as String? ?? '',
      eventName: json['eventName'] as String? ?? '',
      ticketType: json['ticketType'] as String? ?? '',
      organizerName: json['organizerName'] as String? ?? '',
      originalOwnerEmail: json['originalOwnerEmail'] as String? ?? '',
      price: json['price'] as double? ?? 0.0,
      currency: json['currency'] as String? ?? '',
    );
  }

  final String ticketId;
  final String eventName;
  final String ticketType;
  final String organizerName;
  final String originalOwnerEmail;
  final double price;
  final String currency;
}
