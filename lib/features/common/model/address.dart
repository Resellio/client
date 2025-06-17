import 'package:equatable/equatable.dart';

class Address extends Equatable {
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
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      street: json['street'] as String? ?? '',
      houseNumber: json['houseNumber'] as int? ?? 0,
      flatNumber: json['flatNumber'] as int?,
    );
  }

  final String country;
  final String city;
  final String postalCode;
  final String street;
  final int houseNumber;
  final int? flatNumber;

  String get fullAddress {
    final buffer = StringBuffer()
      ..write('$street $houseNumber')
      ..write((flatNumber != null && flatNumber != 0) ? '/$flatNumber' : '')
      ..write(', $city');
    return buffer.toString();
  }

  @override
  List<Object?> get props =>
      [country, city, postalCode, street, houseNumber, flatNumber];
}
