import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:resellio/features/common/model/address.dart';
import 'package:resellio/features/user/events/views/event_details.dart';

class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.minimumAge,
    required this.minimumPrice,
    required this.minimumPriceCurrency,
    required this.maximumPrice,
    required this.maximumPriceCurrency,
    required this.categories,
    required this.status,
    required this.address,
    this.tickets = const [],
    this.revenue = -1.0,
    this.ticketsSold = -1,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime? tryParseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(dateString);
      } catch (err) {
        debugPrint('Error parsing date: $dateString, Error: $err');
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
      minimumPrice:
          ((json['minimumPrice'] as Map<String, dynamic>?)?['price'] as num?)
                  ?.toDouble() ??
              0.0,
      minimumPriceCurrency: ((json['minimumPrice']
              as Map<String, dynamic>?)?['currency'] as String?) ??
          '',
      maximumPrice:
          ((json['maximumPrice'] as Map<String, dynamic>?)?['price'] as num?)
                  ?.toDouble() ??
              0.0,
      maximumPriceCurrency: ((json['maximumPrice']
              as Map<String, dynamic>?)?['currency'] as String?) ??
          '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map(
                (item) =>
                    (item as Map<String, dynamic>?)?['name'] as String? ?? '',
              )
              .toList() ??
          [],
      status: json['status'] as int? ?? 0,
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
      tickets: (json['ticketTypes'] as List<dynamic>?)
              ?.map((item) => TicketType.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      revenue: json['revenue'] as double? ?? -1.0,
      ticketsSold: json['soldTicketsCount'] as int? ?? -1,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Bilety dostepne';
      case 1:
        return 'Zakończony';
      case 2:
        return 'W trakcie';
      case 3:
        return 'Wyprzedany';
      default:
        return 'Nieznany';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int minimumAge;
  final double minimumPrice;
  final String minimumPriceCurrency;
  final double maximumPrice;
  final String maximumPriceCurrency;
  final List<String> categories;
  final int status;
  final Address address;
  final double revenue;
  final int ticketsSold;
  final String? imageUrl;
  final List<TicketType> tickets;

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
