import 'package:equatable/equatable.dart';
import 'package:resellio/features/common/model/address.dart';

class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.minimumAge,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.categories,
    required this.status,
    required this.address,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime? tryParseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(dateString);
      } catch (err) {
        print("Error parsing date: $dateString, Error: $err");
        return null;
      }
    }

    return Event(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: tryParseDate(json['startDate'] as String?),
      endDate: tryParseDate(json['endDate'] as String?),
      minimumAge: json['minimumAge'] as int? ?? 0,
      minimumPrice: (json['minimumPrice'] as num?)?.toDouble() ?? 0.0,
      maximumPrice: (json['maximumPrice'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((item) =>
                  (item as Map<String, dynamic>?)?['name'] as String? ?? '')
              .toList() ??
          [],
      status: json['status'] as int? ?? 0,
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
    );
  }

  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int minimumAge;
  final double minimumPrice;
  final double maximumPrice;
  final List<String> categories;
  final int status;
  final Address address;
  // TODO: image url
  // TODO: tickets list

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        minimumAge,
        minimumPrice,
        maximumPrice,
        categories,
        status,
        address,
      ];
}
