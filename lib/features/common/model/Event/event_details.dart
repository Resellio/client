import 'package:resellio/features/common/model/Event/organizer_event.dart';
import 'package:resellio/features/common/model/address.dart';
import 'package:resellio/features/common/model/ticket_type.dart';

class OrganizerEventDetails {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int minimumAge;
  final List<EventCategory> categories;
  final List<TicketType> ticketTypes;
  final EventStatus status;
  final Address address;

  OrganizerEventDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.minimumAge,
    required this.categories,
    required this.ticketTypes,
    required this.status,
    required this.address,
  });

  factory OrganizerEventDetails.fromJson(Map<String, dynamic> json) {
    return OrganizerEventDetails(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String? ?? ''),
      endDate: DateTime.parse(json['endDate'] as String? ?? ''),
      minimumAge: json['minimumAge'] as int? ?? 0,
      categories: (json['categories'] as List?)
              ?.map(
                  (cat) => EventCategory.fromJson(cat as Map<String, dynamic>))
              .toList() ??
          [],
      ticketTypes: (json['ticketTypes'] as List?)
              ?.map((type) => TicketType.fromJson(type as Map<String, dynamic>))
              .toList() ??
          [],
      status: EventStatus.values[json['status'] as int],
      address: Address.fromJson(json['address'] as Map<String, dynamic> ?? {}),
    );
  }
}
