class ResellTicket {
  const ResellTicket({
    required this.id,
    required this.price,
    required this.currency,
    required this.description,
    required this.seats,
  });

  factory ResellTicket.fromJson(Map<String, dynamic> json) {
    return ResellTicket(
      id: json['id'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PLN',
      description: json['description'] as String? ?? '',
      seats: json['seats'] as String? ?? '',
    );
  }

  final String id;
  final double price;
  final String currency;
  final String description;
  final String seats;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'currency': currency,
      'description': description,
      'seats': seats,
    };
  }
}
