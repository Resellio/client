class Address {
  const Address({
    required this.country,
    required this.city,
    required this.postalCode,
    required this.street,
    required this.houseNumber,
    this.flatNumber,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      street: json['street'] as String,
      houseNumber: json['houseNumber'] as int,
      flatNumber: json['flatNumber'] as int?,
    );
  }

  final String country;
  final String city;
  final String postalCode;
  final String street;
  final int houseNumber;
  final int? flatNumber;

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'postalCode': postalCode,
      'street': street,
      'houseNumber': houseNumber,
      if (flatNumber != null) 'flatNumber': flatNumber,
    };
  }

  String get fullAddress {
    final flat = flatNumber != null ? '/$flatNumber' : '';
    return '$street $houseNumber$flat, $postalCode $city, $country';
  }
}
