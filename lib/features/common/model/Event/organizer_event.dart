import 'package:resellio/features/common/model/address.dart';
import 'package:flutter/material.dart';

class EventPrice {
  EventPrice({required this.price, required this.currency});

  factory EventPrice.fromJson(Map<String, dynamic> json) {
    return EventPrice(
      price: json['price'] as double? ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }
  final double price;
  final String currency;
}

class EventCategory {
  EventCategory({required this.name});

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(name: json['name'] as String? ?? '');
  }
  final String name;
}

enum EventStatus { ticketsAvailable, soldOut, inProgress, finished, unknown }

class OrganizerEvent {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int minimumAge;
  final EventPrice minimumPrice;
  final EventPrice maximumPrice;
  final List<EventCategory> categories;
  final EventStatus status;
  final Address address;

  OrganizerEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.minimumAge,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.categories,
    required this.status,
    required this.address,
  });

  factory OrganizerEvent.fromJson(Map<String, dynamic> json) {
    return OrganizerEvent(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String? ?? ''),
      endDate: DateTime.parse(json['endDate'] as String? ?? ''),
      minimumAge: json['minimumAge'] as int? ?? 0,
      minimumPrice: EventPrice.fromJson(
          json['minimumPrice'] as Map<String, dynamic>? ?? {}),
      maximumPrice: EventPrice.fromJson(
          json['maximumPrice'] as Map<String, dynamic>? ?? {}),
      categories: (json['categories'] as List?)
              ?.map(
                  (cat) => EventCategory.fromJson(cat as Map<String, dynamic>))
              .toList() ??
          [],
      status: EventStatus.values[json['status'] as int],
      address: Address.fromJson(json['address'] as Map<String, dynamic> ?? {}),
    );
  }

  String get statusText {
    switch (status) {
      case EventStatus.ticketsAvailable:
        return 'Bilety dostepne';
      case EventStatus.finished:
        return 'Zakończony';
      case EventStatus.inProgress:
        return 'W trakcie';
      case EventStatus.soldOut:
        return 'Wyprzedany';
      default:
        return 'Nieznany';
    }
  }

  Color get statusColor {
    switch (status) {
      case EventStatus.inProgress:
        return Colors.orange;
      case EventStatus.ticketsAvailable:
        return Colors.green;
      case EventStatus.finished:
        return Colors.grey;
      case EventStatus.soldOut:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
